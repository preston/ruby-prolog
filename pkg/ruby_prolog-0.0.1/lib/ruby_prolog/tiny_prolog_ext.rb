def is(*syms,&block)
  $is_cnt ||= 0
  is = pred "IS_#{$is_cnt += 1}"
  raise "At least one symbol needed" unless syms.size > 0
  is[*syms].calls do |env|
    value = block.call(*syms[1..-1].map{|x| env[x]})
    env.unify(syms.first, value)
  end
  is[*syms]
end

def method_missing(meth, *args)
  case caller[0]
  when /^[^:]*tiny_prolog.rb.*:/
    super
  else
    p = pred meth
    Object.class_eval{ define_method(meth){p} }
    p
  end
end

#write = pred "write"
write[:X].calls{|env| print env[:X]; true}
#writenl = pred "writenl"
writenl[:X].calls{|env| puts env[:X]; true}
#nl = pred "nl"
nl[:X].calls{|e| puts; true}
eq[:X,:Y].calls{|env| env.unify(env[:X], env[:Y])}
noteq[:X,:Y].calls{|env| env[:X] != env[:Y]}
atomic[:X].calls do |env|
  case env[:X]
  when Symbol, Pred, Goal; false
  else true
  end
end
notatomic[:X].calls do |env|
  case env[:X]
  when Symbol, Pred, Goal; true
  else false
  end
end
numeric[:X].calls{|env| Numeric === env[:X] }

