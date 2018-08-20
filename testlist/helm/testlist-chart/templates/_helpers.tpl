{{/*
Determine image string prefix
*/}}
{{- define "testlist-chart.image-prefix" -}}
    {{- if .Values.image.registry -}}
        {{- printf "%s/" .Values.image.registry }}
    {{- end -}}
{{- end -}}

{{/*
Determine image string prefix
*/}}
{{- define "testlist-chart.image-suffix" -}}
    {{- if .Values.image.tag -}}
        {{- printf ":%s" (toString .Values.image.tag) }}
    {{- end -}}
{{- end -}}

{{/*
Determine image string (based on repo/name/tag) where repo and tag are optional.
*/}}
{{- define "testlist-chart.image" -}}
    {{- include "testlist-chart.image-prefix" . -}}
    {{- .Values.image.name -}}
    {{- include "testlist-chart.image-suffix" . -}}
{{- end -}}
