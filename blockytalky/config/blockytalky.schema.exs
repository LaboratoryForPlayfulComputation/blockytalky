[
  mappings: [
    "url.host": [
      doc: "url for path realization",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.url.host",
      datatype: :binary,
      default: "localhost"
    ],
    "http.port": [
      doc: "http port to run endpoint on",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.http.port",
      datatype: :integer,
      default: 80
    ],
    "cache_static_manifest": [
      doc: "static manifest for brunch built files",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest",
      datatype: :binary,
      default: "priv/static/manifest.json"
    ],
    "server": [
      doc: "whether the server should start auto-magically without mix phoenix.server",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.server",
      datatype: :atom,
      default: true
    ],
    "blockytalky.dax": [
      doc: "location of comms webservice",
      to: "blockytalky.dax",
      datatype: :binary,
      default: "ws://btrouter.getdown.org:8005/dax"
    ],
    "blockytalky.music": [
      doc: "whether music blocks, genservers, etc. should be running. requires sonic pi to be running",
      to: "blockytalky.music",
      datatype: :atom,
      default: false
    ],
    "blockytalky.music_port": [
      doc: " music port blockytalky listens to messages from sonic pi on",
      to: "blockytalky.music_port",
      datatype: :integer,
      default: 9090
    ],
    "blockytalky.update_rate": [
      doc: "update rate of hw polling and user code loop iteration, in ms",
      to: "blockytalky.update_rate",
      datatype: :integer,
      default: 30
    ],
    "blockytalky.update_rate_hibernate": [
      doc: "Provide documentation for blockytalky.update_rate_hibernate here.",
      to: "blockytalky.update_rate_hibernate",
      datatype: :integer,
      default: 100
    ],
    "blockytalky.supported_hardware": [
      doc: "list of supported hardware python modules in priv/hw_apis",
      to: "blockytalky.supported_hardware",
      datatype: [
        list: :atom
      ],
      default: [
        :btbrickpi
      ]
    ],
  ],
  translations: [
  ]
]
