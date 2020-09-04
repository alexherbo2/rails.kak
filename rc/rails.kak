# Save the rails paths
declare-option -hidden str rails_plugin_path %sh(dirname "$kak_source")
declare-option -hidden str rails_connect_path "%opt{rails_plugin_path}/connect"

hook global ModuleLoaded rails %{
  rails-detect
}

provide-module rails %{
  # Modules
  require-module connect

  # Register our paths
  set-option -add global connect_paths "%opt{rails_connect_path}/aliases" "%opt{rails_connect_path}/commands"

  # Internal variables
  declare-option -docstring 'Rails enabled' bool rails_enabled
  declare-option -docstring 'Rails root path' str rails_root_path %sh(git rev-parse --show-toplevel)
  declare-option -docstring 'Rails controller name' str rails_controller_name
  declare-option -docstring 'Rails action name' str rails_action_name

  # Rails detection
  define-command -hidden rails-detect %{
    evaluate-commands %sh(test -e "${kak_opt_rails_root_path}/config/environment.rb" && printf rails-enable)
  }

  # Enable Rails
  define-command rails-enable -docstring 'Enable Rails' %{
    set-option global rails_enabled true

    # Aliases
    hook -group rails global WinCreate .* %{
      rails-add-aliases
    }

    # Navigation – Controller ⇒ View
    hook -group rails global WinCreate '.+/app/controllers/(\w+)_controller\.rb' %{
      set-option window rails_controller_name %val{hook_param_capture_1}
      map -docstring 'View' window goto f '<esc>: rails-navigate-from-controller-to-view<ret>'
    }

    # Navigation – Controller ⇒ View (Application)
    hook -group rails global WinCreate '.+/app/controllers/application_controller\.rb' %{
      map -docstring 'View' window goto f '<esc>: rails-edit-view-application<ret>'
    }

    # Navigation – View ⇒ Controller
    hook -group rails global WinCreate '.+/app/views/(\w+)/(\w+)\.html\.erb' %{
      set-option window rails_controller_name %val{hook_param_capture_1}
      set-option window rails_action_name %val{hook_param_capture_2}
      map -docstring 'Controller' window goto f '<esc>: rails-navigate-from-view-to-controller<ret>'
    }

    # Navigation – View ⇒ Controller (Application)
    hook -group rails global WinCreate '.+/app/views/layouts/application\.html\.erb' %{
      map -docstring 'Controller' window goto f '<esc>: rails-edit-controller-application<ret>'
    }
  }

  # Disable Rails
  define-command rails-disable -docstring 'Disable Rails' %{
    remove-hooks global rails

    set-option global rails_enabled false
  }

  # Add aliases
  define-command -hidden rails-add-aliases %{
    # MVC
    alias window model rails-edit-model
    alias window view rails-edit-view
    alias window controller rails-edit-controller

    # Ditto, to [e]dit [m]odel, [v]iew and [c]ontroller.
    alias window em rails-edit-model
    alias window ev rails-edit-view
    alias window ec rails-edit-controller

    # Policy
    alias window policy rails-edit-policy
    alias window ep rails-edit-policy

    # Routes
    alias window routes rails-edit-routes
    alias window routes? rails-show-routes
    alias window rr rails-show-routes

    # Database
    alias window migration rails-edit-migration
    alias window schema rails-edit-schema
    alias window seeds rails-edit-seeds

    # JavaScript and CSS
    alias window js rails-edit-javascript
    alias window css rails-edit-stylesheet
  }

  # Remove aliases
  define-command -hidden rails-remove-aliases %{
    # MVC
    unalias window model
    unalias window view
    unalias window controller

    # Ditto
    unalias window em # [e]dit [m]odel
    unalias window ev # [e]dit [v]iew
    unalias window ec # [e]dit [c]ontroller

    # Policy
    unalias window policy
    unalias window ep # [e]dit [p]olicy

    # Routes
    unalias window routes
    unalias window routes?
    unalias window rr # [r]ails [r]outes

    # Database
    unalias window migration
    unalias window schema
    unalias window seeds

    # JavaScript and CSS
    unalias window js
    unalias window css
  }

  # Rails – Show routes
  define-command rails-show-routes -params .. -docstring 'Rails – Show routes' %{
    $ :rails-show-routes %arg{@}
  }

  # Rails – Edit – Model
  define-command rails-edit-model -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/models" && fd --type file' -docstring 'Edit model' %{
    try %{
      edit "%opt{rails_root_path}/app/models/%arg{1}"
    } catch %{
      rails-edit-model-application
    }
  }

  # Rails – Edit – Model – Application
  define-command rails-edit-model-application -docstring 'Edit application model' %{
    edit "%opt{rails_root_path}/app/models/application_record.rb"
  }

  # Rails – Edit – View
  define-command rails-edit-view -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/views" && fd --type file' -docstring 'Edit view' %{
    try %{
      edit "%opt{rails_root_path}/app/views/%arg{1}"
    } catch %{
      rails-edit-view-application
    }
  }

  # Rails – Edit – View – Application
  define-command rails-edit-view-application -docstring 'Edit application view' %{
    edit "%opt{rails_root_path}/app/views/layouts/application.html.erb"
  }

  # Rails – Edit – Controller
  define-command rails-edit-controller -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/controllers" && fd --type file' -docstring 'Edit controller' %{
    try %{
      edit "%opt{rails_root_path}/app/controllers/%arg{1}"
    } catch %{
      rails-edit-controller-application
    }
  }

  # Rails – Edit – Controller – Application
  define-command rails-edit-controller-application -docstring 'Edit application controller' %{
    edit "%opt{rails_root_path}/app/controllers/application_controller.rb"
  }

  # Rails – Edit – Policy
  define-command rails-edit-policy -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/policies" && fd --type file' -docstring 'Edit policy' %{
    try %{
      edit "%opt{rails_root_path}/app/policies/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/policies/application_policy.rb"
    }
  }

  # Rails – Edit – Routes
  define-command rails-edit-routes -docstring 'Edit routes' %{
    edit "%opt{rails_root_path}/config/routes.rb"
  }

  # Rails – Edit – Database – Migration
  define-command rails-edit-migration -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/db/migrate" && fd --type file' -docstring 'Edit database migration' %{
    try %{
      edit "%opt{rails_root_path}/db/migrate/%arg{1}"
    } catch %{
      edit %sh(find "${kak_opt_rails_root_path}/db/migrate" -type f | sort | tail -1)
    }
  }

  # Rails – Edit – Database – Schema
  define-command rails-edit-schema -docstring 'Edit database schema' %{
    edit "%opt{rails_root_path}/db/schema.rb"
  }

  # Rails – Edit – Database – Seeds
  define-command rails-edit-seeds -docstring 'Edit database seeds' %{
    edit "%opt{rails_root_path}/db/seeds.rb"
  }

  # Rails – Edit – JavaScript
  define-command rails-edit-javascript -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/javascript" && fd --type file' -docstring 'Edit JavaScript file' %{
    try %{
      edit "%opt{rails_root_path}/app/javascript/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/javascript/packs/application.js"
    }
  }

  # Rails – Edit – Stylesheet
  define-command rails-edit-stylesheet -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/assets/stylesheets" && fd --type file' -docstring 'Edit stylesheet file' %{
    try %{
      edit "%opt{rails_root_path}/app/assets/stylesheets/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/assets/stylesheets/application.css.scss"
    } catch %{
      edit "%opt{rails_root_path}/app/assets/stylesheets/application.css"
    }
  }

  # Navigation – Controller ⇒ View
  define-command -hidden rails-navigate-from-controller-to-view -docstring 'Navigate from the controller to its view' %{
    # Search and set action name
    evaluate-commands -draft %{
      execute-keys '<space><a-x>;<a-/>^\h+def\h+(\w+)<ret>1s<ret>'
      set-option window rails_action_name %val{selection}
    }

    try %{
      edit -existing "%opt{rails_root_path}/app/views/%opt{rails_controller_name}/%opt{rails_action_name}.html.erb"
    }
  }

  # Navigation – View ⇒ Controller
  define-command -hidden rails-navigate-from-view-to-controller -docstring 'Navigate from the view to its controller' %{
    try %{
      edit -existing "%opt{rails_root_path}/app/controllers/%opt{rails_controller_name}_controller.rb"
      execute-keys 'gg'
      evaluate-commands -save-regs '/' %{
        set-register / "^\h+def\h+(%opt{rails_action_name})"
        execute-keys '/<ret>1s<ret>'
      }
      execute-keys 'vt'
    }
  }
}

require-module rails
