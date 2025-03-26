{{- define "mongo-outbound.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}
