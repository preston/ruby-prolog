# Based on tiny_prolog h18.9/8
# Fuglied by Preston Lee.
module RubyProlog

  def self.new(&block)
    c = Core.new
    c.instance_eval(&block) if block_given?
    c
  end

  class Predicate
    @@id_counter = 0

    attr_reader :id, :name
    attr_accessor :db, :clauses

    def initialize(db, name)
      @id = (@@id_counter += 1)
      @db = db
      @name = name
      @clauses = []
    end

    def inspect
      return @name.to_s
    end

    def [](*args)
      return TempClause.new(@db, self, args)
    end

    def to_prolog
      @clauses.map do |head, body|
        "#{head.to_prolog}#{body ? " :- #{body.to_prolog}" : ''}."
      end.join("\n")
    end

    def fork(new_db)
      dupe = self.clone
      dupe.db = new_db
      dupe.clauses = dupe.clauses.dup
      dupe
    end
  end

  class TempClause
    def initialize(db, pred, args)
      @db, @pred, @args = db, pred, args
    end

    def si(*rhs)
      goals = rhs.map do |x|
        case x
        when TempClause then x.to_goal
        else x
        end
      end
      @db.append(self.to_goal, list(*goals))
    end

    def fact
      si
    end

    def <<(rhs)
      case rhs
      when Array
        si(*rhs)
      else
        si(rhs)
      end
    end

    def calls(&callback)
      @db.append(self.to_goal, callback)
    end

    def to_goal
      Goal.new(@pred.id, @pred.name, @args.map do |arg|
        case arg
        when TempClause
          arg.to_goal
        else
          arg
        end
      end)
    end

    private

    def list(*x)
      y = nil
      x.reverse_each {|e| y = Cons.new(e, y)}
      return y
    end
  end

  class Goal

    attr_reader :pred_id, :pred_name, :args

    def initialize(pred_id, pred_name, args)
      @pred_id, @pred_name, @args = pred_id, pred_name, args
    end

    def inspect
      return @pred_name.to_s + @args.inspect.to_s
    end

    def to_prolog
      args_out = @args.map do |arg|
        case arg
        when Symbol
          if arg == :_
            "_"
          elsif /[[:upper:]]/.match(arg.to_s[0])
            arg.to_s
          else
            "_#{arg.to_s}"
          end
        when String
          "'#{arg}'"
        when Cons, Goal
          arg.to_prolog
        when Numeric
          arg.to_s
        else
          raise "Unknown argument: #{arg.inspect}"
        end
      end.join(', ')

      if @pred_name == :not_
        "\\+ #{args_out}"
      else
        "#{@pred_name}(#{args_out})"
      end
    end
  end


  # Lisp
  class Cons < Array

    def initialize(car, cdr)
      super(2)
      self[0], self[1] = car, cdr
    end

    def inspect
      repr = proc {|x|
        car, cdr = x[0], x[1]
        if cdr.nil? then [car.inspect]
        elsif Cons === cdr then repr[cdr].unshift(car.inspect)
        else [car.inspect, '.', cdr.inspect]
        end
      }
      return '(' + repr[self].join(' ') + ')'
    end

    def to_prolog
      current = self
      array = []
      while current
        array << case current[0]
          when :CUT then '!'
          when :_ then '_'
          else current[0].to_prolog
          end
        current = current[1]
      end
      return array.join(', ')
    end
  end


  class Environment

    def initialize
      @table = {}
    end

    def put(x, pair)
      @table[x] = pair
    end

    def get(x)
      return @table[x]
    end

    def delete(x)
      @table.delete(x) {|k| raise "#{k} not found in #{inspect}"}
    end

    def clear
      @table.clear
    end

    def solution
      @table.map do |var, env|
        xp = env
        loop {
          x, x_env = xp
          y, y_env = x_env.dereference(x)
          next_xp = y_env.get(x)
          if next_xp.nil?
            xp = [y, y_env]
            break
          else
            xp = next_xp
          end
        }
        [var, xp[0]]
      end.to_h
    end

    def dereference(t)
      env = self
      while Symbol === t
        p = env.get(t)
        break if p.nil?
        t, env = p
      end
      return [t, env]
    end

    def [](t)
      t, env = dereference(t)
      return case t
             when Goal then Goal.new(t.pred_id, t.pred_name, env[t.args])
             when Cons then Cons.new(env[t[0]], env[t[1]])
             when Array then t.collect {|e| env[e]}
             else t
             end
    end


  end


  class CallbackEnvironment

    def initialize(env, trail, core)
      @env, @trail, @core = env, trail, core
    end

    def [](t)
      return @env[t]
    end

    def unify(t, u)
      # pp "CORE " + @core
      return @core._unify(t, @env, u, @env, @trail, @env)
    end

  end


  class Database
    attr_reader :by_name, :by_id

    def initialize
      @by_name = {}
      @by_id = {}
      @listing_enabled = false
      @listing = {}
    end

    def register(pred_name, skip_listing: false)
      pred = @by_name[pred_name] = Predicate.new(self, pred_name)
      @by_id[pred.id] = pred
      @listing[pred.id] = false if skip_listing
      pred
    end

    def enable_listing(flag=true)
      @listing_enabled = true
    end

    def append(head, body)
      pred = @by_id[head.pred_id]
      if pred.nil?
        raise "No such predicate for head: #{head.inspect}"
      end
      pred.clauses << [head, body]
      if @listing_enabled && @listing[pred.id] != false
        # Ruby hashes maintain insertion order
        @listing[pred.id] = true
      end
    end

    def initialize_copy(orig)
      super
      @by_id = @by_id.transform_values do |pred|
        pred.fork(self)
      end
      @by_name = @by_name.transform_values {|pred| @by_id[pred.id]}
    end

    def listing
      @listing.select{|_,v| v}.map{|k,v| @by_id[k]}
    end
  end


  class Core

    def _unify(x, x_env, y, y_env, trail, tmp_env)

      loop {
        if x == :_
          return true
        elsif Symbol === x
          xp = x_env.get(x)
          if xp.nil?
            y, y_env = y_env.dereference(y)
            unless x == y and x_env == y_env
              x_env.put(x, [y, y_env])
              trail << [x, x_env] unless x_env == tmp_env
            end
            return true
          else
            x, x_env = xp
            x, x_env = x_env.dereference(x)
          end
        elsif Symbol === y
          x, x_env, y, y_env = y, y_env, x, x_env
        else
          break
        end
      }

      if Goal === x and Goal === y
        return false unless x.pred_id == y.pred_id
        x, y = x.args, y.args
      end

      if Array === x and Array === y
        return false unless x.length == y.length
        for i in 0 ... x.length     # x.each_index do |i| も可
          return false unless _unify(x[i], x_env, y[i], y_env, trail, tmp_env)
        end
        return true
      else
        return x == y
      end

    end


    def list(*x)
      y = nil
      x.reverse_each {|e| y = Cons.new(e, y)}
      return y
    end


    def resolve(*goals)
      env = Environment.new
      _resolve_body(list(*goals), env, [false]) {
        yield env
      }
    end


    def _resolve_body(body, env, cut)
      if body.nil?
        yield
      else
        goal, rest = body
        if goal == :CUT
          _resolve_body(rest, env, cut) {
            yield
          }
          cut[0] = true
        else
          d_env = Environment.new
          d_cut = [false]
          for d_head, d_body in @db.by_id[goal.pred_id].clauses
            break if d_cut[0] or cut[0]
            trail = []
            if _unify_(goal, env, d_head, d_env, trail, d_env)
              if Proc === d_body
                if d_body[CallbackEnvironment.new(d_env, trail, self)]
                  _resolve_body(rest, env, cut) {
                    yield
                  }
                end
              else
                _resolve_body(d_body, d_env, d_cut) {
                  _resolve_body(rest, env, cut) {
                    yield
                  }
                  d_cut[0] ||= cut[0]
                }
              end
            end
            for x, x_env in trail
              x_env.delete(x)
            end
            d_env.clear
          end
        end
      end
    end


    $_trace = false
    def trace(flag)
      $_trace = flag
    end


    def _unify_(x, x_env, y, y_env, trail, tmp_env)
      lhs, rhs = x_env[x].inspect, y.inspect if $_trace
      unified = _unify(x, x_env, y, y_env, trail, tmp_env)
      printf("\t%s %s %s\n", lhs, (unified ? "~" : "!~"), rhs) if $_trace
      return unified
    end


    def query(&block)
      goals = instance_eval(&block)
      goals = [goals] unless goals.is_a?(Array)
      results = []

      resolve(*goals.map(&:to_goal)) {|env|
        results << env.solution
      }
      return results
    end


    def is(*syms,&block)
      $is_cnt ||= 0
      is = @db.register("IS_#{$is_cnt += 1}", skip_listing: true)
      raise "At least one symbol needed" unless syms.size > 0
      is[*syms].calls do |env|
        value = block.call(*syms[1..-1].map{|x| env[x]})
        env.unify(syms.first, value)
      end
      is[*syms]
    end

    def method_missing(meth, *args)
      pred = @db.register(meth)

      # We only want to define the method on this specific object instance to avoid polluting global namespaces.
      define_singleton_method(meth){ @db.by_name[meth] }

      pred
    end

    def to_prolog
      @db.listing.map(&:to_prolog).join("\n\n")
    end


    def initialize
      @db = Database.new
      # These predicates are made available in all environments
      write[:X].calls{|env| print env[:X]; true}
      writenl[:X].calls{|env| puts env[:X]; true}
      nl[:X].calls{|e| puts; true}
      eq[:X,:Y].calls{|env| env.unify(env[:X], env[:Y])}
      noteq[:X,:Y].calls{|env| env[:X] != env[:Y]}
      atomic[:X].calls do |env|
        case env[:X]
        when Symbol, Predicate, Goal; false
        else true
        end
      end
      notatomic[:X].calls do |env|
        case env[:X]
        when Symbol, Predicate, Goal; true
        else false
        end
      end
      numeric[:X].calls{|env| Numeric === env[:X] }

      not_[:X].calls do |env|
        found_solution = false
        resolve(env[:X], :CUT) { found_solution = true }
        found_solution == false
      end

      # Enable here so the predicates above don't make it in to_prolog output
      @db.enable_listing
    end

    def initialize_copy(orig)
      super
      @db = @db.clone
    end
  end

end
