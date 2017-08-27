defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions
  """

  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be -h or --help witch returns :help
  Otherwise it is a github user name, project name and (optionally the numer of entries)

  Return a tuple of `{user, project, count}` or `:help`
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
      switches: [ help: :boolean ],
      aliases: [ h: :help ])

    case parse do
      { [help: true], _, _ } -> :help

      { _, [ user, project, count ], _ }
        -> { user, project, String.to_integer(count) }

      { _, [ user, project ], _ }
        -> { user, project, @default_count }

      _ -> :help
    end
  end

end


