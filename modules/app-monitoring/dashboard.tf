// modules/app-monitoring/dashboard.tf

############################################
# Grafana Dashboard Provisioning (via Helm)
# - AMP (Prometheus): metrics
# - Loki: logs
# - Tempo: traces
############################################

locals {
  grafana_dashboard_provider_name = "app-observability"
  grafana_dashboard_folder        = "✨ App Observability"

  grafana_dashboard_path      = "/var/lib/grafana/dashboards/${local.grafana_dashboard_provider_name}"
  grafana_home_dashboard_path = "${local.grafana_dashboard_path}/app-observability.json"

  # Grafana chart reads this and creates provisioning file under /etc/grafana/provisioning/dashboards/
  grafana_dashboard_providers = {
    "dashboardproviders.yaml" = {
      apiVersion = 1
      providers = [
        {
          name                  = local.grafana_dashboard_provider_name
          orgId                 = 1
          folder                = local.grafana_dashboard_folder
          type                  = "file"
          disableDeletion       = false
          editable              = true
          allowUiUpdates        = true
          updateIntervalSeconds = 10
          options = {
            path = local.grafana_dashboard_path
          }
        }
      ]
    }
  }

  # Grafana chart reads this and creates ConfigMap(s) with dashboard JSON files.
  grafana_dashboards = {
    (local.grafana_dashboard_provider_name) = {
      "app-observability" = {
        json = local.grafana_dashboard_app_observability_json
      }
    }
  }

  # Dashboard JSON (stored as a JSON string)
  grafana_dashboard_app_observability_json = jsonencode({
    uid   = "app-obs-lgtm"
    title = "🌈 App Observability (AMP + Loki + Tempo)"

    timezone      = "browser"
    schemaVersion = 39
    version       = 1
    refresh       = "30s"

    tags = ["lgtm", "amp", "loki", "tempo", "kubernetes", "golden-signals"]

    time = {
      from = "now-6h"
      to   = "now"
    }

    links = [
      {
        title = "Explore Metrics (AMP)"
        type  = "link"
        url   = "/explore?left=%7B%22datasource%22:%22AMP%22%7D"
      },
      {
        title = "Explore Logs (Loki)"
        type  = "link"
        url   = "/explore?left=%7B%22datasource%22:%22Loki%22%7D"
      },
      {
        title = "Explore Traces (Tempo)"
        type  = "link"
        url   = "/explore?left=%7B%22datasource%22:%22Tempo%22%7D"
      }
    ]

    annotations = {
      list = [
        {
          builtIn    = 1
          datasource = "-- Grafana --"
          enable     = true
          hide       = true
          iconColor  = "rgba(0, 211, 255, 1)"
          name       = "Annotations & Alerts"
          type       = "dashboard"
        }
      ]
    }

    templating = {
      list = [
        {
          name       = "namespace"
          label      = "Namespace"
          type       = "query"
          datasource = "AMP"
          refresh    = 2
          multi      = true
          includeAll = true
          allValue   = ".*"
          sort       = 1
          query      = "label_values(up, namespace)"
          current = {
            text  = "All"
            value = "$__all"
          }
        },
        {
          name       = "pod"
          label      = "Pod"
          type       = "query"
          datasource = "AMP"
          refresh    = 2
          multi      = true
          includeAll = true
          allValue   = ".*"
          sort       = 1
          query      = "label_values(up{namespace=~\"$namespace\"}, pod)"
          current = {
            text  = "All"
            value = "$__all"
          }
        },
        {
          name       = "service"
          label      = "Service"
          type       = "query"
          datasource = "AMP"
          refresh    = 2
          multi      = false
          includeAll = true
          allValue   = ".*"
          sort       = 1
          query      = "label_values(up{namespace=~\"$namespace\"}, service)"
          current = {
            text  = "All"
            value = "$__all"
          }
        },
        {
          name  = "search"
          label = "Log search"
          type  = "textbox"
          query = ""
          current = {
            text  = ""
            value = ""
          }
        }
      ]
    }

    panels = [
      {
        id    = 1
        type  = "row"
        title = "🔭 Overview"
        gridPos = { x = 0, y = 0, w = 24, h = 1 }
        collapsed = false
        panels    = []
      },
      {
        id         = 2
        type       = "stat"
        title      = "🚀 Requests / sec"
        datasource = "AMP"
        gridPos    = { x = 0, y = 1, w = 6, h = 5 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "horizontal"
          textMode      = "value_and_name"
          colorMode     = "value"
          graphMode     = "area"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit = "req/s"
            min  = 0
            thresholds = {
              mode  = "absolute"
              steps = [{ color = "green", value = null }, { color = "yellow", value = 10 }, { color = "red", value = 100 }]
            }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "sum(rate(http_requests_total{namespace=~\"$namespace\"}[5m]))", legendFormat = "rps" }]
      },
      {
        id         = 3
        type       = "stat"
        title      = "🧨 5xx error ratio"
        datasource = "AMP"
        gridPos    = { x = 6, y = 1, w = 6, h = 5 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "horizontal"
          textMode      = "value_and_name"
          colorMode     = "background"
          graphMode     = "none"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit     = "percentunit"
            min      = 0
            max      = 1
            decimals = 2
            thresholds = {
              mode  = "absolute"
              steps = [{ color = "green", value = null }, { color = "yellow", value = 0.01 }, { color = "red", value = 0.05 }]
            }
          }
          overrides = []
        }
        targets = [{
          refId        = "A"
          expr         = "sum(rate(http_requests_total{namespace=~\"$namespace\",status=~\"5..\"}[5m])) / sum(rate(http_requests_total{namespace=~\"$namespace\"}[5m]))"
          legendFormat = "5xx ratio"
        }]
      },
      {
        id         = 4
        type       = "stat"
        title      = "⏱️ p95 latency"
        datasource = "AMP"
        gridPos    = { x = 12, y = 1, w = 6, h = 5 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "horizontal"
          textMode      = "value_and_name"
          colorMode     = "value"
          graphMode     = "area"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit     = "s"
            min      = 0
            decimals = 3
            thresholds = {
              mode  = "absolute"
              steps = [{ color = "green", value = null }, { color = "yellow", value = 0.25 }, { color = "red", value = 1.0 }]
            }
          }
          overrides = []
        }
        targets = [{
          refId        = "A"
          expr         = "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{namespace=~\"$namespace\"}[5m])) by (le))"
          legendFormat = "p95"
        }]
      },
      {
        id         = 5
        type       = "stat"
        title      = "🧠 CPU (cores)"
        datasource = "AMP"
        gridPos    = { x = 18, y = 1, w = 6, h = 5 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "horizontal"
          textMode      = "value_and_name"
          colorMode     = "value"
          graphMode     = "area"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit     = "cores"
            min      = 0
            decimals = 2
            thresholds = {
              mode  = "absolute"
              steps = [{ color = "green", value = null }, { color = "yellow", value = 1 }, { color = "red", value = 4 }]
            }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "sum(rate(container_cpu_usage_seconds_total{namespace=~\"$namespace\",container!=\"\"}[5m]))", legendFormat = "cpu" }]
      },
      {
        id         = 6
        type       = "timeseries"
        title      = "📈 Golden signals"
        datasource = "AMP"
        gridPos    = { x = 0, y = 6, w = 24, h = 8 }
        fieldConfig = {
          defaults = {
            unit = "short"
            thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "red", value = 0 }] }
          }
          overrides = [
            { matcher = { id = "byName", options = "p95 latency" }, properties = [{ id = "unit", value = "s" }] },
            { matcher = { id = "byName", options = "5xx ratio" }, properties = [{ id = "unit", value = "percentunit" }] },
          ]
        }
        options = {
          legend  = { displayMode = "table", placement = "bottom", calcs = ["lastNotNull", "max"] }
          tooltip = { mode = "multi" }
        }
        targets = [
          { refId = "A", expr = "sum(rate(http_requests_total{namespace=~\"$namespace\"}[5m]))", legendFormat = "rps" },
          { refId = "B", expr = "sum(rate(http_requests_total{namespace=~\"$namespace\",status=~\"5..\"}[5m])) / sum(rate(http_requests_total{namespace=~\"$namespace\"}[5m]))", legendFormat = "5xx ratio" },
          { refId = "C", expr = "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{namespace=~\"$namespace\"}[5m])) by (le))", legendFormat = "p95 latency" },
        ]
      },

      {
        id    = 10
        type  = "row"
        title = "☸️ Kubernetes"
        gridPos = { x = 0, y = 14, w = 24, h = 1 }
        collapsed = false
        panels    = []
      },
      {
        id         = 11
        type       = "bargauge"
        title      = "🔥 Top CPU pods"
        datasource = "AMP"
        gridPos    = { x = 0, y = 15, w = 12, h = 8 }
        options = {
          displayMode   = "gradient"
          orientation   = "horizontal"
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          showUnfilled  = true
        }
        fieldConfig = {
          defaults = {
            unit     = "cores"
            decimals = 2
            min      = 0
            thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "yellow", value = 0.25 }, { color = "red", value = 1.0 }] }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "topk(10, sum(rate(container_cpu_usage_seconds_total{namespace=~\"$namespace\",pod=~\"$pod\",container!=\"\"}[5m])) by (pod))", legendFormat = "{{pod}}" }]
      },
      {
        id         = 12
        type       = "bargauge"
        title      = "🧊 Top Memory pods"
        datasource = "AMP"
        gridPos    = { x = 12, y = 15, w = 12, h = 8 }
        options = {
          displayMode   = "gradient"
          orientation   = "horizontal"
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          showUnfilled  = true
        }
        fieldConfig = {
          defaults = {
            unit     = "bytes"
            decimals = 2
            min      = 0
            thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "yellow", value = 1073741824 }, { color = "red", value = 4294967296 }] }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "topk(10, sum(container_memory_working_set_bytes{namespace=~\"$namespace\",pod=~\"$pod\",container!=\"\"}) by (pod))", legendFormat = "{{pod}}" }]
      },
      {
        id         = 13
        type       = "table"
        title      = "🔁 Recent container restarts (last 1h)"
        datasource = "AMP"
        gridPos    = { x = 0, y = 23, w = 12, h = 7 }
        options = {
          showHeader = true
          sortBy     = [{ desc = true, displayName = "Value" }]
        }
        fieldConfig = { defaults = { unit = "short", decimals = 0 }, overrides = [] }
        transformations = [{
          id = "organize"
          options = {
            indexByName  = { Time = 0, pod = 1, Value = 2 }
            renameByName = { Value = "Restarts" }
          }
        }]
        targets = [{ refId = "A", expr = "topk(20, sum(increase(kube_pod_container_status_restarts_total{namespace=~\"$namespace\"}[1h])) by (pod))", legendFormat = "{{pod}}", format = "table" }]
      },
      {
        id         = 14
        type       = "stat"
        title      = "✅ Pods Ready (ratio)"
        datasource = "AMP"
        gridPos    = { x = 12, y = 23, w = 6, h = 7 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "vertical"
          colorMode     = "value"
          textMode      = "value_and_name"
          graphMode     = "area"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit     = "percentunit"
            min      = 0
            max      = 1
            decimals = 2
            thresholds = { mode = "absolute", steps = [{ color = "red", value = null }, { color = "yellow", value = 0.8 }, { color = "green", value = 0.95 }] }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "sum(kube_pod_status_ready{namespace=~\"$namespace\",condition=\"true\"}) / sum(kube_pod_status_ready{namespace=~\"$namespace\"})", legendFormat = "ready" }]
      },
      {
        id         = 15
        type       = "stat"
        title      = "⚠️ Pending / Failed pods"
        datasource = "AMP"
        gridPos    = { x = 18, y = 23, w = 6, h = 7 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "vertical"
          colorMode     = "background"
          textMode      = "value_and_name"
          graphMode     = "none"
          justifyMode   = "center"
        }
        fieldConfig = {
          defaults = {
            unit     = "short"
            min      = 0
            decimals = 0
            thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "yellow", value = 1 }, { color = "red", value = 5 }] }
          }
          overrides = []
        }
        targets = [{ refId = "A", expr = "sum(kube_pod_status_phase{namespace=~\"$namespace\",phase=~\"Pending|Failed\"})", legendFormat = "unhealthy" }]
      },

      {
        id    = 20
        type  = "row"
        title = "🧾 Logs (Loki)"
        gridPos = { x = 0, y = 30, w = 24, h = 1 }
        collapsed = false
        panels    = []
      },
      {
        id         = 21
        type       = "timeseries"
        title      = "📊 Log volume (lines/sec)"
        datasource = "Loki"
        gridPos    = { x = 0, y = 31, w = 12, h = 8 }
        options = {
          legend  = { displayMode = "table", placement = "bottom", calcs = ["lastNotNull", "max"] }
          tooltip = { mode = "multi" }
        }
        fieldConfig = { defaults = { unit = "ops", min = 0 }, overrides = [] }
        targets = [{ refId = "A", expr = "sum(rate({namespace=~\"$namespace\",pod=~\"$pod\"}[1m]))", legendFormat = "lines/sec" }]
      },
      {
        id         = 22
        type       = "piechart"
        title      = "🍬 Logs by level (best-effort)"
        datasource = "Loki"
        gridPos    = { x = 12, y = 31, w = 12, h = 8 }
        options = {
          legend        = { displayMode = "list", placement = "right" }
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          pieType       = "pie"
          displayLabels = ["name", "percent"]
        }
        fieldConfig = { defaults = { unit = "short", decimals = 0 }, overrides = [] }
        targets = [{
          refId        = "A"
          expr         = "sum by (level) (count_over_time({namespace=~\"$namespace\",pod=~\"$pod\"} | json | label_format level={{.level}} [5m]))"
          legendFormat = "{{level}}"
        }]
      },
      {
        id         = 23
        type       = "logs"
        title      = "🧻 Live logs"
        datasource = "Loki"
        gridPos    = { x = 0, y = 39, w = 24, h = 14 }
        options = {
          showTime         = true
          showLabels       = true
          showCommonLabels = true
          wrapLogMessage   = true
          dedupStrategy    = "signature"
          enableLogDetails = true
          sortOrder        = "Descending"
        }
        targets = [{ refId = "A", expr = "{namespace=~\"$namespace\",pod=~\"$pod\"} |= \"$search\"" }]
      },

      {
        id    = 30
        type  = "row"
        title = "🧵 Traces (Tempo)"
        gridPos = { x = 0, y = 53, w = 24, h = 1 }
        collapsed = false
        panels    = []
      },
      {
        id         = 31
        type       = "traces"
        title      = "🕵️ Trace search (TraceQL)"
        datasource = "Tempo"
        gridPos    = { x = 0, y = 54, w = 24, h = 10 }
        options = {
          spanStartTimeShift = "0s"
          spanEndTimeShift   = "0s"
        }
        targets = [{
          refId     = "A"
          queryType = "traceql"
          query     = "{ resource.service.name =~ \"$service\" }"
        }]
      },
      {
        id         = 32
        type       = "stat"
        title      = "🧬 Traces seen (best-effort)"
        datasource = "AMP"
        gridPos    = { x = 0, y = 64, w = 8, h = 6 }
        options = {
          reduceOptions = { calcs = ["lastNotNull"], fields = "", values = false }
          orientation   = "vertical"
          colorMode     = "value"
          textMode      = "value_and_name"
          graphMode     = "area"
          justifyMode   = "center"
        }
        fieldConfig = { defaults = { unit = "short", min = 0 }, overrides = [] }
        targets = [{ refId = "A", expr = "sum(rate(traces_spanmetrics_calls_total{service=~\"$service\"}[5m]))", legendFormat = "calls/s" }]
      },
      {
        id         = 33
        type       = "timeseries"
        title      = "🧷 Span latency (p95, best-effort)"
        datasource = "AMP"
        gridPos    = { x = 8, y = 64, w = 16, h = 6 }
        options = {
          legend  = { displayMode = "table", placement = "bottom", calcs = ["lastNotNull", "max"] }
          tooltip = { mode = "multi" }
        }
        fieldConfig = { defaults = { unit = "s", min = 0, decimals = 3 }, overrides = [] }
        targets = [{ refId = "A", expr = "histogram_quantile(0.95, sum(rate(traces_spanmetrics_latency_bucket{service=~\"$service\"}[5m])) by (le))", legendFormat = "span p95" }]
      }
    ]
  })
}

