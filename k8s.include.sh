# shared functions for including in k8s helper scripts.

get_all_non_event_resource_types() {
    printf -- '%s' "$(kubectl api-resources --verbs=list --namespaced -o name | grep -v '^events$' | grep -v '^events.events.k8s.io$' | sort | uniq)"
}
