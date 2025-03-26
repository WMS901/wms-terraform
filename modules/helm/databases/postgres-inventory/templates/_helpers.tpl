{{- define "postgres-inventory.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}
