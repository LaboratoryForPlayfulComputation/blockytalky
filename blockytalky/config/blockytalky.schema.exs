[
  mappings: [
    "blockytalky.Elixir.Blockytalky.Endpoint.url.host": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.url.host",
      datatype: :binary,
      default: "localhost"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.root": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.root",
      datatype: :binary,
      default: "/opt/blockytalky"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base",
      datatype: :binary,
      default: "Kr/XoPRzKE/LIrVn2ugw8mtnkftj3C83hhELSbR49ZXM1HkljuB7rUTlOOX8e9zT"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors",
      datatype: :atom,
      default: false
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name",
      datatype: :atom,
      default: Blockytalky.PubSub
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter",
      datatype: :atom,
      default: Phoenix.PubSub.PG2
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.http.port": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.http.port",
      datatype: :integer,
      default: 80
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest",
      datatype: :binary,
      default: "priv/static/manifest.json"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.server": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Endpoint.server",
      datatype: :atom,
      default: true
    ],
    "blockytalky.dax": [
      doc: "",
      to: "blockytalky.dax",
      datatype: :binary,
      default: "ws://btrouter.getdown.org:8005/dax"
    ],
    "blockytalky.music": [
      doc: "",
      to: "blockytalky.music",
      datatype: :atom,
      default: true
    ],
    "blockytalky.music_port": [
      doc: "",
      to: "blockytalky.music_port",
      datatype: :integer,
      default: 9090
    ],
    "blockytalky.update_rate": [
      doc: "",
      to: "blockytalky.update_rate",
      datatype: :integer,
      default: 30
    ],
    "blockytalky.update_rate_hibernate": [
      doc: "",
      to: "blockytalky.update_rate_hibernate",
      datatype: :integer,
      default: 100
    ],
    "blockytalky.supported_hardware": [
      doc: "",
      to: "blockytalky.supported_hardware",
      datatype: [
        list: :atom
      ],
      default: [
        :btbrickpi
      ]
    ],
    "blockytalky.user_code_dir": [
      doc: "",
      to: "blockytalky.user_code_dir",
      datatype: :binary,
      default: "/opt/blockytalky/usercode"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.adapter": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Repo.adapter",
      datatype: :atom,
      default: Ecto.Adapters.Postgres
    ],
    "blockytalky.Elixir.Blockytalky.Repo.username": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Repo.username",
      datatype: :binary,
      default: "postgres"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.password": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Repo.password",
      datatype: :binary,
      default: "postgres"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.database": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Repo.database",
      datatype: :binary,
      default: "blockytalky_prod"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.size": [
      doc: "",
      to: "blockytalky.Elixir.Blockytalky.Repo.size",
      datatype: :integer,
      default: 20
    ],
    "logger.console.format": [
      doc: "",
      to: "logger.console.format",
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """
    ],
    "logger.console.metadata": [
      doc: "",
      to: "logger.console.metadata",
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ]
    ],
    "logger.level": [
      doc: "",
      to: "logger.level",
      datatype: :atom,
      default: :info
    ],
    "logger.backends": [
      doc: "",
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
      doc: "",
      to: "logger.syslog.facility",
      datatype: :atom,
      default: :local2
    ],
    "logger.syslog.appid": [
      doc: "",
      to: "logger.syslog.appid",
      datatype: :binary,
      default: "BlockyTalky"
    ]
  ],
  translations: [
  ]
]
