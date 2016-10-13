defmodule ExCoveralls.CustomJson do
  @moduledoc """
  Generate Custom JSON output for results.
  """

  alias ExCoveralls.Local.Count

  @file_name "excoveralls_custom.json"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    generate_json(stats, Enum.into(options, %{})) |> write_file

    ExCoveralls.Local.print_summary(stats)
  end

  def generate_json(stats, _options) do
    JSX.encode!([
      source_files: stats,
      percentage_coverage: percentage_coverage(stats)
    ])
  end

  defp get_coverage(count) do
    case count.relevant do
      0 -> default_coverage_value()
      _ -> (count.covered / count.relevant) * 100
    end
  end

  defp output_dir do
    options = ExCoveralls.Settings.get_coverage_options
    case Dict.fetch(options, "output_dir") do
      {:ok, val} -> val
      _ -> "cover/"
    end
  end

  defp percentage_coverage(stats) do
    count_info = Enum.map(stats, fn(stat) -> [stat, ExCoveralls.Local.calculate_count(stat[:coverage])] end)
    totals   = Enum.reduce(count_info, %Count{}, fn([_, count], acc) -> append(count, acc) end)
    get_coverage(totals)
  end

  defp write_file(content) do
    file_path = output_dir()
    unless File.exists?(file_path) do
      File.mkdir!(file_path)
    end
    File.write!(Path.expand(@file_name, file_path), content)
  end

  defp default_coverage_value do
    options = ExCoveralls.Settings.get_coverage_options
    case Dict.fetch(options, "treat_no_relevant_lines_as_covered") do
      {:ok, true} -> 100.0
      _           -> 0.0
    end
  end

  defp append(a, b) do
    %Count{
      lines: a.lines + b.lines,
      relevant: a.relevant + b.relevant,
      covered: a.covered  + b.covered
    }
  end

end
