{{/*
Determine image string prefix
*/}}
{{- define "testwatch-chart.image-prefix" -}}
    {{- if .Values.image.registry -}}
        {{- printf "%s/" .Values.image.registry }}
    {{- end -}}
{{- end -}}

{{/*
Determine image string prefix
*/}}
{{- define "testwatch-chart.image-suffix" -}}
    {{- if .Values.image.tag -}}
        {{- printf ":%s" (toString .Values.image.tag) }}
    {{- end -}}
{{- end -}}

{{/*
Determine image string (based on repo/name/tag) where repo and tag are optional.
*/}}
{{- define "testwatch-chart.image" -}}
    {{- include "testwatch-chart.image-prefix" . -}}
    {{- .Values.image.name -}}
    {{- include "testwatch-chart.image-suffix" . -}}
{{- end -}}
