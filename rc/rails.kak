hook global ModuleLoaded rails %{
  rails-detect
}

provide-module rails %{

  # Internal variables
  declare-option -docstring 'Rails root path' str rails_root_path %sh(git rev-parse --show-toplevel)

  # Rails detection
  define-command -hidden rails-detect %{
    evaluate-commands %sh(test -e "${kak_opt_rails_root_path}/config/environment.rb" && printf rails-enable)
  }

  # Enable Rails
  define-command rails-enable -docstring 'Enable Rails' %{
    hook -group rails global WinSetOption 'filetype=.*' %{
      # Aliases
      rails-add-aliases

      # Clean settings
      hook -always -once window WinSetOption 'filetype=.*' %{
        rails-remove-aliases
      }
    }
  }

  # Disable Rails
  define-command rails-disable -docstring 'Disable Rails' %{
    remove-hooks global rails
    rails-remove-aliases
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

    # Database
    unalias window migration
    unalias window schema
    unalias window seeds

    # JavaScript and CSS
    unalias window js
    unalias window css
  }

  # Rails – Edit – Model
  define-command rails-edit-model -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/models" && fd --type file' -docstring 'Edit model' %{
    try %{
      edit "%opt{rails_root_path}/app/models/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/models/application_record.rb"
    }
  }

  # Rails – Edit – View
  define-command rails-edit-view -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/views" && fd --type file' -docstring 'Edit view' %{
    try %{
      edit "%opt{rails_root_path}/app/views/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/views/layouts/application.html.erb"
    }
  }

  # Rails – Edit – Controller
  define-command rails-edit-controller -params 0..1 -shell-script-candidates 'cd "${kak_opt_rails_root_path}/app/controllers" && fd --type file' -docstring 'Edit controller' %{
    try %{
      edit "%opt{rails_root_path}/app/controllers/%arg{1}"
    } catch %{
      edit "%opt{rails_root_path}/app/controllers/application_controller.rb"
    }
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
}

require-module rails
