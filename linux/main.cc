#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/io.h>

#include "flutter/generated_plugins.h"

#define APPLICATION_ID "com.prospectius"

static void my_application_activate(GApplication* application) {
  FlView* view = fl_view_new();
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, nullptr);

  g_autoptr(FlViewProperties) properties = fl_view_properties_new();
  fl_view_set_view_properties(view, properties);

  fl_view_set_project(view, project);

  GtkApplication* gtk_application = GTK_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(gtk_application));

  gtk_window_set_default_size(window, 800, 600);
  gtk_window_set_title(window, "Prospectius");

  gtk_widget_show(GTK_WIDGET(window));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

int main(int argc, char** argv) {
  g_autoptr(GtkApplication) application =
      gtk_application_new(APPLICATION_ID, G_APPLICATION_FLAGS_NONE);
  g_signal_connect(application, "activate", G_CALLBACK(my_application_activate),
                   nullptr);
  int status = g_application_run(G_APPLICATION(application), argc, argv);
  return status;
}
