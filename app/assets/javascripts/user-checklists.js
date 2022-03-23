// Javascript for user-checklist views

//= require 'utilities'

var UserChecklists = {

  SET_COMPLETE_URL: "/anvandare/lista/set-all-completed/",
  SET_UNCOMPLE_URL: "/anvandare/lista/set-all-uncompleted/",
  TOGGLE_ALL_URL: "/anvandare/lista/all_changed_by_completion_toggle/",

  PROGRESS_BAR_ID: "#progress-bar",
  PROGRESS_BAR_CLASS: ".progress-bar",
  PERCENT_TEXT_CLASS: ".percent-text",

  ALL_COMPLETE: 100,
  ALL_COMPLETE_CLASS: 'is-complete',

  NONE_COMPLETE: 0,
  NONE_COMPLETE_CLASS: 'none-complete',

  toggleAllUrl: function (checklistId) {
    return UserChecklists.TOGGLE_ALL_URL + checklistId.toString();
  },


  urlForCheckboxEle: function (checkboxElementId, checklistId) {
    let checkboxElement = $(checkboxElementId);
    let baseURL = (checkboxElement.prop("checked") ? UserChecklists.SET_COMPLETE_URL : UserChecklists.SET_UNCOMPLE_URL);
    return baseURL + checklistId;
  },


  postCheckboxChanged: function (checkboxId, checklistId, successCallback) {
    postUrl = UserChecklists.urlForCheckboxEle(checkboxId, checklistId);
    Utility.postUrl(postUrl, successCallback);
  },


  updateProgressBarFromResponse: function (responseData, progressBarElem, completeText = 'klar') {
    let newPercentComplete = responseData.overall_percent_complete;
    UserChecklists.updateProgressBar(newPercentComplete, progressBarElem, completeText);
  },


  updateProgressBar: function (progressPercent = 0, progressBar = $(progressBarClass), complete_text = 'klar') {
    let percentText = progressBar.find(UserChecklists.PERCENT_TEXT_CLASS);
    let progressPercentString = progressPercent + "%";
    percentText.text(progressPercentString + " " + complete_text);
    progressBar.innerWidth(progressPercentString);
    progressBar.attr('aria-valuenow', progressPercent);
    UserChecklists.progressBarSetClass(progressBar, progressPercent, UserChecklists.NONE_COMPLETE, UserChecklists.NONE_COMPLETE_CLASS);
    UserChecklists.progressBarSetClass(progressBar, progressPercent, UserChecklists.ALL_COMPLETE, UserChecklists.ALL_COMPLETE_CLASS);
  },


  progressBarSetClass: function (progressBar, percent, comparisonValue, cssClass) {
    (percent === comparisonValue) ? progressBar.addClass(cssClass) : progressBar.removeClass(cssClass);
  },


  dateCompletedText: function (dateCompleted = "", dateCompletedI18n = "") {
    return (dateCompleted === "") ? "" :  dateCompletedI18n + ": " +  dateCompleted;
  }

};
