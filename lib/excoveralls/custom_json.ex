defmodule ExCoveralls.CustomJson do
  @moduledoc """
  Generate Custom JSON output for results.
  """

  # alias ExCoveralls.Local.Count

  @file_name "excoveralls_custom.json"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    generate_json(stats, Enum.into(options, %{})) |> write_file

    ExCoveralls.Local.print_summary(stats)

    ExCoveralls.Stats.ensure_minimum_coverage(stats)
  end

  def generate_json(stats, _options) do
    JSX.encode!([
      source_files: stats,
      percentage_coverage: ExCoveralls.Stats.source(stats).coverage
    ])
  end

  defp output_dir do
    options = ExCoveralls.Settings.get_coverage_options
    case Dict.fetch(options, "output_dir") do
      {:ok, val} -> val
      _ -> "cover/"
    end
  end

  defp write_file(content) do
    file_path = output_dir()
    unless File.exists?(file_path) do
      File.mkdir!(file_path)
    end
    File.write!(Path.expand(@file_name, file_path), content)
  end
end
