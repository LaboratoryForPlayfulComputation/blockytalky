[
  mappings: [
    "blockytalky.Elixir.Blockytalky.Endpoint.url.host": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.url.host here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.url.host",
      datatype: :binary,
      default: "localhost"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.root": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.root here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.root",
      datatype: :binary,
      default: "/vagrant/blockytalky"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base",
      datatype: :binary,
      default: "Kr/XoPRzKE/LIrVn2ugw8mtnkftj3C83hhELSbR49ZXM1HkljuB7rUTlOOX8e9zT"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.debug_errors here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors",
      datatype: :atom,
      default: false
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name",
      datatype: :atom,
      default: Blockytalky.PubSub
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter",
      datatype: :atom,
      default: Phoenix.PubSub.PG2
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.http.port": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.http.port here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.http.port",
      datatype: :integer,
      default: 80
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest",
      datatype: :binary,
      default: "priv/static/manifest.json"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.server": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.server here.",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.server",
      datatype: :atom,
      default: true
    ],
    "blockytalky.dax": [
      doc: "Provide documentation for blockytalky.dax here.",
      to: "blockytalky.dax",
      datatype: :binary,
      default: "ws://btrouter.getdown.org:8005/dax"
    ],
    "blockytalky.music": [
      doc: "Provide documentation for blockytalky.music here.",
      to: "blockytalky.music",
      datatype: :atom,
      default: true
    ],
    "blockytalky.music_port": [
      doc: "Provide documentation for blockytalky.music_port here.",
      to: "blockytalky.music_port",
      datatype: :integer,
      default: 9090
    ],
    "blockytalky.update_rate": [
      doc: "Provide documentation for blockytalky.update_rate here.",
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
      doc: "Provide documentation for blockytalky.supported_hardware here.",
      to: "blockytalky.supported_hardware",
      datatype: [
        list: :atom
      ],
      default: [
        :btbrickpi
      ]
    ],
    "blockytalky.Elixir.Blockytalky.Repo.adapter": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.adapter here.",
      to: "blockytalky.Elixir.Blockytalky.Repo.adapter",
      datatype: :atom,
      default: Ecto.Adapters.Postgres
    ],
    "blockytalky.Elixir.Blockytalky.Repo.username": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.username here.",
      to: "blockytalky.Elixir.Blockytalky.Repo.username",
      datatype: :binary,
      default: "postgres"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.password": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.password here.",
      to: "blockytalky.Elixir.Blockytalky.Repo.password",
      datatype: :binary,
      default: "postgres"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.database": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.database here.",
      to: "blockytalky.Elixir.Blockytalky.Repo.database",
      datatype: :binary,
      default: "blockytalky_prod"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.size": [
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.size here.",
      to: "blockytalky.Elixir.Blockytalky.Repo.size",
      datatype: :integer,
      default: 20
    ],
    "logger.console.format": [
      doc: "Provide documentation for logger.console.format here.",
      to: "logger.console.format",
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """
    ],
    "logger.console.metadata": [
      doc: "Provide documentation for logger.console.metadata here.",
      to: "logger.console.metadata",
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ]
    ],
    "logger.level": [
      doc: "Provide documentation for logger.level here.",
      to: "logger.level",
      datatype: :atom,
      default: :info
    ],
    "logger.backends": [
      doc: "Provide documentation for logger.backends here.",
      to: "logger.backends",
      datatype: [
        list: :atom
      ],
      default: [
        Logger.Backends.Syslog,
        :console
      ]
    ],
    "logger.syslog.facility": [
      doc: "Provide documentation for logger.syslog.facility here.",
      to: "logger.syslog.facility",
      datatype: :atom,
      default: :local2
    ],
    "logger.syslog.appid": [
      doc: "Provide documentation for logger.syslog.appid here.",
      to: "logger.syslog.appid",
      datatype: :binary,
      default: "BlockyTalky"
    ]
  ],
  translations: [
  ]
]
