Drone plugin to generate conventional commit changelogs. You are able to
automatically update your changelog if you are using commit messages following
the conventional commit definition.

## Examples

```yaml
kind: pipeline
name: default

steps:
- name: step name
  image: dronehippie/chglog:1
  settings: []
```

## Parameters

dummy
: dummy
