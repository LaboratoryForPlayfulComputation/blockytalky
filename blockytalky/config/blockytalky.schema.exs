@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "blockytalky.Elixir.Blockytalky.Endpoint.url.host": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.url.host here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.url.host"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.root": [
      commented: false,
      datatype: :binary,
      default: "/Users/matt/blockytalky_elixir/blockytalky",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.root here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.root"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base": [
      commented: false,
      datatype: :binary,
      default: "Kr/XoPRzKE/LIrVn2ugw8mtnkftj3C83hhELSbR49ZXM1HkljuB7rUTlOOX8e9zT",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.secret_key_base"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.debug_errors here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.debug_errors"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name": [
      commented: false,
      datatype: :atom,
      default: Blockytalky.PubSub,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.name"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter": [
      commented: false,
      datatype: :atom,
      default: Phoenix.PubSub.PG2,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.pubsub.adapter"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.check_origin": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.check_origin here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.check_origin"
    ],
    "web.http.port": [
      commented: false,
      datatype: :integer,
      default: 80,
      doc: "The http port Blockytalky listens on",
      hidden: false,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.http.port"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest": [
      commented: false,
      datatype: :binary,
      default: "priv/static/manifest.json",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.cache_static_manifest"
    ],
    "blockytalky.Elixir.Blockytalky.Endpoint.server": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Endpoint.server here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Endpoint.server"
    ],
    "dax": [
      commented: false,
      datatype: :binary,
      default: "ws://btrouter.getdown.org:8005/dax",
      doc: "The remote messaging broker url.",
      hidden: false,
      to: "blockytalky.dax"
    ],
    "music": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Whether music blocks + music runtime system are enabled",
      hidden: false,
      to: "blockytalky.music"
    ],
    "music_port": [
      commented: false,
      datatype: :integer,
      default: 9090,
      doc: "The port sonic pi listens on in the custom loop case (depreciated)",
      hidden: true,
      to: "blockytalky.music_port"
    ],
    "music_eval_port": [
      commented: false,
      datatype: :integer,
      default: 5050,
      doc: "The port sonic pi responds to",
      hidden: true,
      to: "blockytalky.music_eval_port"
    ],
    "update_rate": [
      commented: false,
      datatype: :integer,
      default: 30,
      doc: "The time in milliseconds BT programs sleep",
      hidden: false,
      to: "blockytalky.update_rate"
    ],
    "update_rate_hibernate": [
      commented: false,
      datatype: :integer,
      default: 100,
      doc: "The time in milliseconds between BT HW polls while a program is not running",
      hidden: false,
      to: "blockytalky.update_rate_hibernate"
    ],
    "supported_hardware": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :btbrickpi
      ],
      doc: "The list of currently connected hardware, i.e. mock, btbrickpi, btgrovepi",
      hidden: false,
      to: "blockytalky.supported_hardware"
    ],
    "blockytalky.user_code_dir": [
      commented: false,
      datatype: :binary,
      default: "/opt/blockytalky/usercode",
      doc: "The directory user code gets saved to",
      hidden: false,
      to: "blockytalky.user_code_dir"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.adapter": [
      commented: false,
      datatype: :atom,
      default: Ecto.Adapters.Postgres,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.adapter here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Repo.adapter"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.username": [
      commented: false,
      datatype: :binary,
      default: "postgres",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.username here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Repo.username"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.password": [
      commented: false,
      datatype: :binary,
      default: "postgres",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.password here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Repo.password"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.database": [
      commented: false,
      datatype: :binary,
      default: "blockytalky_prod",
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.database here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Repo.database"
    ],
    "blockytalky.Elixir.Blockytalky.Repo.size": [
      commented: false,
      datatype: :integer,
      default: 20,
      doc: "Provide documentation for blockytalky.Elixir.Blockytalky.Repo.size here.",
      hidden: true,
      to: "blockytalky.Elixir.Blockytalky.Repo.size"
    ],
    "logger.console.format": [
      commented: false,
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """,
      doc: "Provide documentation for logger.console.format here.",
      hidden: true,
      to: "logger.console.format"
    ],
    "logger.console.metadata": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ],
      doc: "Provide documentation for logger.console.metadata here.",
      hidden: true,
      to: "logger.console.metadata"
    ],
    "logger.level": [
      commented: false,
      datatype: :atom,
      default: :info,
      doc: "Provide documentation for logger.level here.",
      hidden: true,
      to: "logger.level"
    ],
    "logger.backends": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        Logger.Backends.Syslog,
        :console
      ],
      doc: "Provide documentation for logger.backends here.",
      hidden: true,
      to: "logger.backends"
    ],
    "logger.syslog.facility": [
      commented: false,
      datatype: :atom,
      default: :local2,
      doc: "Provide documentation for logger.syslog.facility here.",
      hidden: true,
      to: "logger.syslog.facility"
    ],
    "logger.syslog.appid": [
      commented: false,
      datatype: :binary,
      default: "BlockyTalky",
      doc: "Provide documentation for logger.syslog.appid here.",
      hidden: true,
      to: "logger.syslog.appid"
    ]
  ],
  transforms: [],
  validators: []
]
