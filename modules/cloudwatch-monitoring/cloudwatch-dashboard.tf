resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  dashboard_name = "eks-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "apiserver_request_total_4XX", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "API Server 4XX Requests"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "apiserver_request_total_5XX", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "API Server 5XX Requests"
        }
      },
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "scheduler_schedule_attempts_ERROR", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Scheduler Errors"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "scheduler_pending_pods_UNSCHEDULABLE", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Pending Pods (Unschedulable)"
        }
      },
      {
        type = "metric",
        x = 0,
        y = 12,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "apiserver_request_total_429", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Throttled Requests (429)"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 12,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EKS", "apiserver_request_duration_seconds_LIST_P99", "ClusterName", "wms-cluster", { "region" = "us-east-1" } ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "LIST Request Duration P99"
        }
      }
    ]
  })
}
