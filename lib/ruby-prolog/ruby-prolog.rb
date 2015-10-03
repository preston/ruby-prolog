# Based on tiny_prolog h18.9/8
# Fuglied by Preston Lee.
module RubyProlog

  
  class Predicate
  
    attr_reader :defs

    def initialize(name)
      @name = name
      @defs = []
    end

    def inspect
      return @name.to_s
    end

    def [](*args)
      return Goal.new(self, args)
    end

  end


  class Goal

    attr_reader :pred, :args

    def list(*x)
      y = nil
      x.reverse_each {|e| y = Cons.new(e, y)}
      return y
    end
    
    def initialize(pred, args)
      @pred, @args = pred, args
    end

    def si(*rhs)
      @pred.defs << [self, list(*rhs)]
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
      @pred.defs << [self, callback]
    end

    def inspect
      return @pred.inspect.to_s + @args.inspect.to_s
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
             when Goal then Goal.new(t.pred, env[t.args])
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


  class Core

    def _unify(x, x_env, y, y_env, trail, tmp_env)

      loop {
        if Symbol === x
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
        return false unless x.pred == y.pred
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
          require 'pp'
          # pp 'G ' + goal.class.to_s
          # pp goal.pred
          for d_head, d_body in goal.pred.defs
          # for d_head, d_body in goal.defs
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


    def query(*goals)
      count = 0
      results = Array.new
      # printout = proc {|x|
      #   x = x[0] if x.length == 1
      #   printf "%d %s\n", count, x.inspect
      # }
      resolve(*goals) {|env|
        count += 1
        results << env[goals]
        # printout[env[goals]]
      }
      # printout[goals] if count == 0
      return results
    end
  
  
    def is(*syms,&block)
      $is_cnt ||= 0
      is = Predicate.new "IS_#{$is_cnt += 1}"
      raise "At least one symbol needed" unless syms.size > 0
      is[*syms].calls do |env|
        value = block.call(*syms[1..-1].map{|x| env[x]})
        env.unify(syms.first, value)
      end
      is[*syms]
    end

    def method_missing(meth, *args)
        # puts "NEW PRED #{meth} #{meth.class}"
        pred = Predicate.new(meth)

        # We only want to define the method on this specific object instance to avoid polluting global namespaces.
        define_singleton_method(meth){ pred }

        return pred
    end

  
    def initialize
      # We do not need to predefine predicates like this because they will automatically be defined for us.
      # write = Predicate.new "write"
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
    end

  end

end
