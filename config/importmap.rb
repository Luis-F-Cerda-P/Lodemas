# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "flowbite", to: "flowbite.turbo.min.js"
pin "@stimulus-components/notification", to: "@stimulus-components--notification.js" # @3.0.0
pin "stimulus-use" # @0.52.3
