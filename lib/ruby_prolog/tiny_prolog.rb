# Ruby による簡単な Prolog 処理系 h18.9/8 (鈴)

# Prolog の述語 (predicate)
class Pred
  attr_reader :defs
  def initialize(name)
    @name = name
    @defs = []
  end
  def inspect
    return @name
  end
  def [](*args)
    return Goal.new(self, args)
  end
  def []=(*a); end
end

def pred(x) return Pred.new(x) end

# Prolog のゴール
class Goal
  attr_reader :pred, :args
  def initialize(pred, args)
    @pred, @args = pred, args
  end
  def si(*rhs)                  # ラテン語の「もしも」
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

# Lisp のリスト風の二項組
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

def cons(car, cdr) return Cons.new(car, cdr) end

def list(*x)
  y = nil
  x.reverse_each {|e| y = cons(e, y)}
  return y
end


# Prolog の環境 (environment)
class Env
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
           when Cons then cons(env[t[0]], env[t[1]])
           when Array then t.collect {|e| env[e]}
           else t
           end
  end
end

# 単一化関数
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


# ゴール (の並び) を解決した環境を返す (内部) イテレータ
def resolve(*goals)
  env = Env.new
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
      d_env = Env.new
      d_cut = [false]
      for d_head, d_body in goal.pred.defs
        break if d_cut[0] or cut[0]
        trail = []
        if _unify_(goal, env, d_head, d_env, trail, d_env)
          if Proc === d_body
            if d_body[CallbackEnv.new(d_env, trail)]
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

# コールバック用の環境
class CallbackEnv
  def initialize(env, trail)
    @env, @trail = env, trail
  end
  def [](t)
    return @env[t]
  end
  def unify(t, u)
    return _unify(t, @env, u, @env, @trail, @env)
  end
end

# ゴールに対するすべての解を印字する便宜関数
def query(*goals)
  count = 0
  printout = proc {|x|
    x = x[0] if x.length == 1
    printf "%d %s\n", count, x.inspect
  }
  resolve(*goals) {|env|
    count += 1
    printout[env[goals]]
  }
  printout[goals] if count == 0
end

__END__
