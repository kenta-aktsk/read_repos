defmodule ReadRepos do
  defmacro __using__(opts) do
    primary = __CALLER__.module
    read_repo = Module.split(__CALLER__.module) |> List.first |> Module.concat(ReadRepo)
    quote location: :keep do
      @primary unquote(primary)
      @otp_app unquote(opts)[:otp_app] || Module.get_attribute(@primary, :otp_app)
      @regexp unquote(opts)[:regexp] || Regex.compile!(".*#{unquote(read_repo)}[0-9]+", "i")
      @page_size unquote(opts)[:page_size] || 10
      Module.register_attribute __MODULE__, :replicas, accumulate: true
      @before_compile unquote(__MODULE__)

      contents = quote location: :keep do
        use Ecto.Repo, otp_app: unquote(@otp_app)
        use Scrivener, page_size: unquote(@page_size)
      end

      env = Application.get_all_env(@otp_app)
      Enum.each(env, fn({key, conf}) when is_atom(key) ->
        if Regex.match?(@regexp, Atom.to_string(key)) do
          Module.create(key, contents, Macro.Env.location(__ENV__))
          @replicas key
        end
      end)
    end
  end

  defmacro __before_compile__(env) do
    replicas = Module.get_attribute(env.module, :replicas) |> Enum.reverse
    primary = Module.get_attribute(env.module, :primary)
    count = length(replicas)
    quote location: :keep do
      def replicas do
        unquote(Macro.escape(replicas))
      end
      if unquote(count) > 0 do
        def replica do
          at = Enum.random(0..unquote(Macro.escape(count)) - 1)
          Enum.fetch!(replicas, at)
        end
      else
        def replica do
          unquote(primary)
        end
      end
    end
  end
end
