local Translations = {
  stealmeter = {
    ["target_label"] = "Steal Parking meter",
    ["stealing_animation_label"] = "STEALING METER...",
    ["stealing_animation_canceled"] = "You canceled the action",
    ["already_stolen_error"] = "Someone already stole here",
    ["messed_up_error"] = "YOU MESSED UP!!!",
    ["meter_stolen"] = "You stole the money",
    ["police_notification"] = "Parking meter steal in pogress",
    ["police_notified"] = "The police have been notified!!!",
  },
}
Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
