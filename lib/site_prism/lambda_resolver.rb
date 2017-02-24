module SitePrism
  module LambdaResolver
    def resolve_lambdas(args)
      args.map { |arg| resolve_lambda(arg) }
    end

    def resolve_lambda(arg)
      arg.is_a?(Proc) ? instance_exec(&arg) : arg
    end
  end
end
