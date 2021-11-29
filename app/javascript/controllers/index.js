// Load all the controllers within this directory and all subdirectories. 
// Controller files must be named *_controller.js.

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Autocomplete } from 'stimulus-autocomplete'
import Flatpickr from 'stimulus-flatpickr'

import "flatpickr/dist/flatpickr.css"

const application = Application.start()
const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))

application.register('flatpickr', Flatpickr)
application.register('autocomplete', Autocomplete)

import { Modal } from "tailwindcss-stimulus-components"
application.register('modal', Modal)
