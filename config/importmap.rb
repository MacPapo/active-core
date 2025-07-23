# Pin npm packages by running ./bin/importmap

pin "application"

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin "popper", to: "popper.js", preload: true
pin "bootstrap", to: "bootstrap.js", preload: true
pin "initialize-popovers", to: "initialize-popovers.js"

pin "debounce", to: "debounce.js"
