// ==============================
// Grafana dashboard provisioning
// ==============================

locals {
  grafana_dashboard_app_observability = {
    uid           = "app-observability"
    title         = "App Observability"
    tags          = ["app-monitoring", "lgtm"]
    timezone      = ""
    schemaVersion = 41
    version       = 1
    refresh       = "30s"

    time = {
      from = "now-1h"
      to   = "now"
    }

    templating = {
      list = [
        {
          name       = "service"
          label      = "Service"
          type       = "custom"
          hide       = 0
          multi      = true
          includeAll = true
          allValue   = ".*"
          query      = "order-service,product-service,user-service"
          current = {
            selected = true
            text     = "All"
            value    = "$__all"
          }
        },
        {
          name  = "search"
          label = "Log search"
          type  = "textbox"
          hide  = 0
          query = ""
          current = {
            selected = false
            text     = ""
            value    = ""
          }
        }
      ]
    }

    panels = [
      {
        id    = 100
        type  = "row"
        title = "Overview"
        gridPos = {
          h = 1
          w = 24
          x = 0
          y = 0
        }
        collapsed = false
      },

      // ---- Overview stats ----
      {
        id    = 1
        type  = "stat"
        title = "Requests / sec"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 5
          w = 6
          x = 0
          y = 1
        }
        targets = [
          {
            refId      = "A"
            expr       = "sum(rate(http_requests_total[5m]))"
            legendFormat = "rps"
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "reqps"
            decimals = 4
            min      = 0
            thresholds = {
              mode  = "absolute"
              steps = [
                { color = "green", value = null }
              ]
            }
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation       = "auto"
          textMode          = "auto"
          colorMode         = "background"
          graphMode         = "area"
          justifyMode       = "auto"
          showPercentChange = false
          wideLayout        = true
        }
      },
      {
        id    = 2
        type  = "stat"
        title = "5xx error ratio"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 5
          w = 6
          x = 6
          y = 1
        }
        targets = [
          {
            refId = "A"
            expr  = "(sum(rate(http_requests_total{status=~\"5..|5xx\"}[5m])) or vector(0)) / clamp_min((sum(rate(http_requests_total[5m])) or vector(0)), 1e-9)"
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "percentunit"
            decimals = 2
            min      = 0
            max      = 1
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 0.01 },
                { color = "red", value = 0.05 }
              ]
            }
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation       = "auto"
          textMode          = "auto"
          colorMode         = "background"
          graphMode         = "none"
          justifyMode       = "auto"
          showPercentChange = false
          wideLayout        = true
        }
      },
      {
        id    = 3
        type  = "stat"
        title = "p95 latency"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 5
          w = 6
          x = 12
          y = 1
        }
        targets = [
          {
            refId = "A"
            expr  = "1000 * histogram_quantile(0.95, sum(rate(http_request_duration_highr_seconds_bucket[5m])) by (le))"
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "ms"
            decimals = 3
            min      = 0
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 200 },
                { color = "red", value = 500 }
              ]
            }
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation       = "auto"
          textMode          = "auto"
          colorMode         = "background"
          graphMode         = "area"
          justifyMode       = "auto"
          showPercentChange = false
          wideLayout        = true
        }
      },
      {
        id    = 4
        type  = "stat"
        title = "CPU (cores)"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 5
          w = 6
          x = 18
          y = 1
        }
        targets = [
          {
            refId = "A"
            expr  = "sum(rate(process_cpu_seconds_total[5m]))"
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "cores"
            decimals = 2
            min      = 0
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation       = "auto"
          textMode          = "auto"
          colorMode         = "background"
          graphMode         = "area"
          justifyMode       = "auto"
          showPercentChange = false
          wideLayout        = true
        }
      },

      // ---- Golden signals ----
      {
        id    = 5
        type  = "timeseries"
        title = "Golden signals"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 8
          w = 24
          x = 0
          y = 6
        }
        targets = [
          {
            refId        = "A"
            expr         = "sum(rate(http_requests_total[5m]))"
            legendFormat = "rps"
          },
          {
            refId        = "B"
            expr         = "1000 * histogram_quantile(0.95, sum(rate(http_request_duration_highr_seconds_bucket[5m])) by (le))"
            legendFormat = "p95 latency"
          }
        ]
        fieldConfig = {
          defaults = {
            min = 0
          }
          overrides = [
            {
              matcher = {
                id      = "byName"
                options = "p95 latency"
              }
              properties = [
                {
                  id    = "unit"
                  value = "ms"
                },
                {
                  id = "custom.axisPlacement"
                  value = "right"
                }
              ]
            },
            {
              matcher = {
                id      = "byName"
                options = "rps"
              }
              properties = [
                {
                  id    = "unit"
                  value = "reqps"
                }
              ]
            }
          ]
        }
        options = {
          legend = {
            showLegend  = true
            displayMode = "list"
            placement   = "bottom"
          }
          tooltip = {
            mode = "single"
          }
        }
      },

      // ---- Targets (best-effort process metrics) ----
      {
        id    = 6
        type  = "bargauge"
        title = "Top CPU targets"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 8
          w = 12
          x = 0
          y = 14
        }
        pluginVersion = "12.4.0"
        fieldConfig = {
          defaults = {
            unit = "cores"
            min  = 0
          }
          overrides = []
        }
        options = {
          orientation  = "horizontal"
          displayMode  = "basic"
          showUnfilled = true
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
        }
        targets = [
          {
            editorMode   = "code"
            expr      = "topk(10, sum by (instance) (rate(process_cpu_seconds_total[5m])))"
            legendFormat = "{{instance}}"
            instant      = true
            refId        = "A"
          }
        ]
      },
      {
        id    = 7
        type  = "bargauge"
        title = "Top Memory targets"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 8
          w = 12
          x = 12
          y = 14
        }
        pluginVersion = "12.4.0"
        fieldConfig = {
          defaults = {
            unit = "bytes"
            min  = 0
          }
          overrides = []
        }
        options = {
          orientation  = "horizontal"
          displayMode  = "basic"
          showUnfilled = true
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
        }
        targets = [
          {
            editorMode   = "code"
            expr      = "topk(10, max by (instance) (process_resident_memory_bytes))"
            legendFormat = "{{instance}}"
            instant      = true
            refId        = "A"
          }
        ]
      },
      {
        id    = 8
        type  = "table"
        title = "Process restarts (last 1h)"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 7
          w = 12
          x = 0
          y = 22
        }
        pluginVersion = "12.4.0"
        fieldConfig = {
          defaults = {}
          overrides = []
        }
        targets = [
          {
            editorMode   = "code"
            expr      = "topk(20, sum by (instance) (changes(process_start_time_seconds[1h])))"
            legendFormat = "{{instance}}"
            instant      = false
            refId        = "A"
          }
        ]
        transformations = [
          {
            id = "seriesToRows"
            options = {}
          },
          {
            id = "organize"
            options = {
              excludeByName = {}
              renameByName = {
                Metric = "instance"
                Value  = "Restarts"
              }
              indexByName = {
                Time     = 0
                Restarts = 1
                instance = 2
              }
            }
          }
        ]
        options = {
          showHeader = true
        }
      },
      {
        id    = 9
        type  = "stat"
        title = "Targets Up (ratio)"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 7
          w = 6
          x = 12
          y = 22
        }
        pluginVersion = "12.4.0"
        fieldConfig = {
          defaults = {
            unit = "percentunit"
            min  = 0
            max  = 1
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "red",    value = null },
                { color = "yellow", value = 0.9 },
                { color = "green",  value = 0.99 }
              ]
            }
          }
          overrides = []
        }
        targets = [
          {
            editorMode   = "code"
            expr         = "sum(up) / clamp_min(count(up), 1)"
            legendFormat = "ready"
            refId        = "A"
          }
        ]
        options = {
          colorMode = "value"
          graphMode   = "none"
          justifyMode = "center"
          orientation = "horizontal"
          textMode    = "value_and_name"
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
        }
      },
      {
        id    = 10
        type  = "stat"
        title = "Targets Down"
        datasource = {
          type = "prometheus"
          uid  = "amp"
        }
        gridPos = {
          h = 7
          w = 6
          x = 18
          y = 22
        }
        pluginVersion = "12.4.0"
        fieldConfig = {
          defaults = {
            unit = "short"
            min  = 0
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "red",   value = 1 }
              ]
            }
          }
          overrides = []
        }
        targets = [
          {
            editorMode   = "code"
            expr         = "sum(up == 0)"
            legendFormat = "unhealthy"
            refId        = "A"
          }
        ]
        options = {
          colorMode = "value"
          graphMode   = "none"
          justifyMode = "center"
          orientation = "horizontal"
          textMode    = "value_and_name"
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
        }
      },

      {
        id    = 200
        type  = "row"
        title = "Logs (Loki)"
        gridPos = {
          h = 1
          w = 24
          x = 0
          y = 30
        }
        collapsed = false
      },
      {
        id    = 11
        type  = "timeseries"
        title = "Log volume (lines/sec)"
        datasource = {
          type = "loki"
          uid  = "loki"
        }
        gridPos = {
          h = 8
          w = 12
          x = 0
          y = 31
        }
        targets = [
          {
            refId        = "A"
            expr         = "sum(rate({job=~\".+\"}[1m]))"
            legendFormat = "lines/sec"
          }
        ]
        fieldConfig = {
          defaults = {
            unit = "ops"
            min  = 0
          }
          overrides = []
        }
        options = {
          legend = {
            showLegend  = true
            displayMode = "list"
            placement   = "bottom"
          }
          tooltip = {
            mode = "single"
          }
        }
      },
      {
        id    = 12
        type  = "piechart"
        title = "Logs by level (best-effort)"
        datasource = {
          type = "loki"
          uid  = "loki"
        }
        gridPos = {
          h = 8
          w = 12
          x = 12
          y = 31
        }
        pluginVersion = "12.4.0"
        targets = [
          {
            refId     = "A"
            queryType = "range"
            legendFormat = "{{level}}"
            expr = <<EOT
sum by (level) (
  count_over_time(
    {job=~".+"}
    | regexp "(?i)(level|severity)[:=\\\" ]*(?P<level>trace|debug|info|warn|warning|error|fatal)"
    | label_format level="{{ lower .level }}"
    | level=~".+"
  [5m])
)
EOT
          }
        ]
        fieldConfig = {
          defaults = {
            unit        = "short"
            displayName = "$${__field.labels.level}"
          }
          overrides = [
            {
              matcher = { id = "byName", options = "info" }
              properties = [
                { id = "color", value = { mode = "fixed", fixedColor = "#1F78C1" } }
              ]
            },
            {
              matcher = { id = "byName", options = "warn" }
              properties = [
                { id = "color", value = { mode = "fixed", fixedColor = "#F2CC0C" } }
              ]
            },
            {
              matcher = { id = "byName", options = "warning" }
              properties = [
                { id = "color", value = { mode = "fixed", fixedColor = "#F2CC0C" } }
              ]
            },
            {
              matcher = { id = "byName", options = "error" }
              properties = [
                { id = "color", value = { mode = "fixed", fixedColor = "#E02F44" } }
              ]
            }
          ]
        }
        options = {
          displayLabels = ["name", "percent"]
          legend = {
            showLegend  = true
            displayMode = "list"
            placement   = "right"
            values      = ["value"]
          }
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
        }
        transformations = [
          {
            id = "renameByRegex"
            options = {
              regex         = ".*level=\"([^\"]+)\".*"
              renamePattern = "$1"
            }
          }
        ]

      },
      {
        id    = 13
        type  = "logs"
        title = "Live logs"
        datasource = {
          type = "loki"
          uid  = "loki"
        }
        gridPos = {
          h = 8
          w = 24
          x = 0
          y = 39
        }
        targets = [
          {
            refId = "A"
            expr  = "{job=~\".+\"} |= \"$search\""
          }
        ]
        options = {
          showTime      = true
          showLabels    = true
          wrapLogMessage = true
          sortOrder     = "Descending"
          enableLogDetails = true
        }
      },

      {
        id    = 300
        type  = "row"
        title = "Traces (Tempo)"
        gridPos = {
          h = 1
          w = 24
          x = 0
          y = 51
        }
        collapsed = false
      },
      {
        id    = 14
        type  = "table"
        title = "Trace search (TraceQL)"
        datasource = {
          type = "tempo"
          uid  = "tempo"
        }
        gridPos = {
          h = 12
          w = 24
          x = 0
          y = 52
        }
        targets = [
          {
            refId     = "A"
            queryType = "traceql"
            query     = "{ resource.service.name =~ \"$service\" }"
            limit     = 20
            sps       = 3
          }
        ]
        options = {
          showHeader = true
        }
      },
      {
        id    = 15
        type  = "stat"
        title = "Traces seen (best-effort)"
        datasource = {
          type = "tempo"
          uid  = "tempo"
        }
        gridPos = {
          h = 5
          w = 12
          x = 0
          y = 64
        }
        targets = [
          {
            refId     = "A"
            queryType = "traceql"
            query     = "{ resource.service.name =~ \"$service\" }"
            limit     = 20
            sps       = 3
          }
        ]
        transformations = [
          {
            id = "reduce"
            options = {
              mode   = "seriesToRows"
              reducers = ["count"]
            }
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "short"
            decimals = 0
            thresholds = {
              mode  = "absolute"
              steps = [
                { color = "green", value = null }
              ]
            }
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation = "auto"
          textMode    = "auto"
          colorMode   = "background"
          graphMode   = "none"
          wideLayout  = true
        }
      },
      {
        id    = 16
        type  = "stat"
        title = "Slow traces (>2ms)"
        datasource = {
          type = "tempo"
          uid  = "tempo"
        }
        gridPos = {
          h = 5
          w = 12
          x = 12
          y = 64
        }
        targets = [
          {
            refId     = "A"
            queryType = "traceql"
            query     = "{ resource.service.name =~ \"$service\" && duration > 2ms }"
            limit     = 20
            sps       = 3
          }
        ]
        transformations = [
          {
            id = "reduce"
            options = {
              mode     = "seriesToRows"
              reducers = ["count"]
            }
          }
        ]
        fieldConfig = {
          defaults = {
            unit     = "short"
            decimals = 0
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "red", value = 1 }
              ]
            }
          }
          overrides = []
        }
        options = {
          reduceOptions = {
            calcs  = ["lastNotNull"]
            fields = ""
            values = false
          }
          orientation = "auto"
          textMode    = "auto"
          colorMode   = "background"
          graphMode   = "none"
          wideLayout  = true
        }
      }
    ]
  }
}

resource "kubernetes_config_map_v1" "grafana_dashboard_app_observability" {
  metadata {
    name      = "grafana-dashboard-app-observability"
    namespace = var.namespace

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "app-observability.json" = jsonencode(local.grafana_dashboard_app_observability)
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

