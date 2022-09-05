defmodule Crawler.Fetcher.Requester do
  @moduledoc """
  Makes HTTP requests.
  """

  alias Crawler.HTTP

  @fetch_opts [
    follow_redirect: true,
    max_redirect: 5
  ]

  @scrapingfish_base_url "https://scraping.narf.ai/api/v1/"

  @doc """
  Makes HTTP requests via `Crawler.HTTP`.

  ## Examples

      iex> Requester.make(url: "fake.url", modifier: Crawler.Fetcher.Modifier)
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
  """
  def make(opts) do
    HTTP.get(scrapingfish_url(opts[:url]), fetch_headers(opts), fetch_opts(opts))
  end

  defp fetch_headers(opts) do
    [{"User-Agent", opts[:user_agent]}] ++ opts[:modifier].headers(opts)
  end

  defp fetch_opts(opts) do
    @fetch_opts ++ [recv_timeout: opts[:timeout]] ++ opts[:modifier].opts(opts)
  end

  defp scrapingfish_url(url_to_scrape) do
    %URI{
      URI.parse(@scrapingfish_base_url)
      | query:
          URI.encode_query(
            render_js: true,
            api_key: scrapingfish_api_key(),
            url: url_to_scrape
          )
    }
    |> URI.to_string()
  end

  defp scrapingfish_api_key do
    System.get_env("SF_KEY")
  end
end
