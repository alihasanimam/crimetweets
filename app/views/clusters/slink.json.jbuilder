json.array!(@clusters) do |cluster|
  json.extract! cluster, :id
  json.url cluster_url(cluster, format: :json)
end
