simple_plugin(CurrentModule "service" art_Persistency_Provenance canvas::canvas)
simple_plugin(DatabaseConnection "service")
simple_plugin(FileCatalogMetadata "service")
simple_plugin(FloatingPointControl "service"
  SOURCE FloatingPointControl_service.cc detail/fpControl.cc)
simple_plugin(ScheduleContext "service" art_Framework_Core)
simple_plugin(TriggerNamesService "service")

# NB: Install of services not trivial due to complex name created...

#install_headers(SUBDIRS detail)
#install_source(SUBDIRS detail)
