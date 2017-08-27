defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
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

  def process(:help) do
    IO.puts """
    usar: issues <user> <project> [count | #{@default_count}]
    """
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    { _, message } = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def sort_into_ascending_order(issues) do
    Enum.sort(issues, fn i1, i2 ->
      Map.get(i1, "created_at") <= Map.get(i2, "created_at")
    end)
  end

  def print_table_for_columns(issues, columns) do
    print_table_header(columns)
    print_table_rows(issues)
  end

  defp print_table_header(headers) do
    headers
    |> Enum.join(" | ")
    |> IO.puts
  end

  defp print_table_rows(rows) do
    Enum.each(rows, fn row ->
      [row["number"], row["created_at"], row["title"]]
      |> Enum.join(" | ")
      |> IO.puts
    end)
  end
end


