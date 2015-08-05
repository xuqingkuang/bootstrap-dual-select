#
# jQuery Dual Select plugin with Bootstrap v0.1.0
# http://kuang.it
#
# Copyright (c) 2015 XQ Kuang
# Created by: XQ Kuang <xuqingkuang@gmail.com>
#
# Usage:
#   Create a <select> and apply this script to that select via jQuery like so:
#   $('select').dualSelect(); - the Dual Select will than be created for you.
#
#   Options and parameters can be provided through html5 data-* attributes or
#   via a provided JavaScript object.
#
#   See the default parameters (below) for a complete list of options.

do ($ = jQuery) ->
  # Interface messages
  messages =
    available : 'Available'
    selected  : 'Selected'
    showing   : ' is showing '
    filter    : 'Filter'

  # Template
  # TODO: Use simple template engine to rewrite the code.
  templates =
    'layout': (options) ->
      [
        '<div class="row dual-select">'
          '<div class="col-md-5 dual-select-container" data-area="unselected">'
            '<h4>'
              "<span>#{messages.available} #{options.title}</span>"
              "<small>#{messages.showing}<span class=\"badge count\">0</span></small>"
            '</h4>'
            "<input type=\"text\" placeholder=\"#{messages.filter}\" class=\"form-control filter\">"
            '<select multiple="true" class="form-control" style="height: 160px;"></select>'
          '</div>'
          '<div class="col-md-2 center-block control-buttons"></div>'
          '<div class="col-md-5 dual-select-container" data-area="selected">'
            '<h4>'
              "<span>#{messages.selected} #{options.title}</span>"
              "<small>#{messages.showing}<span class=\"badge count\">0</span></small>"
            '</h4>'
            "<input type=\"text\" placeholder=\"#{messages.filter}\" class=\"form-control filter\">"
            '<select multiple="true" class="form-control" style="height: 160px;"></select>'
          '</div>'
        '</div>'
      ].join('')
    'buttons':
      'allToSelected': [
          '<button type="button" class="btn btn-default col-md-8 col-md-offset-2">'
            '<span class="glyphicon glyphicon-fast-forward"></span>'
          '</button>'
        ].join('')
      'unselectedToSelected': [
          '<button type="button" class="btn btn-default col-md-8 col-md-offset-2">'
            '<span class="glyphicon glyphicon-step-forward"></span>'
          '</button>'
        ].join('')
      'selectedToUnselected': [
          '<button type="button" class="btn btn-default col-md-8 col-md-offset-2">'
            '<span class="glyphicon glyphicon-step-backward"></span>'
          '</button>'
        ].join('')
      'allToUnselected': [
          '<button type="button" class="btn btn-default col-md-8 col-md-offset-2">'
            '<span class="glyphicon glyphicon-fast-backward"></span>'
          '</button>'
        ].join('')

  # Default options, overridable
  $.dualSelect =
    templates: templates
    messages: messages
    defaults:
      # Timeout for when a filter search is started.
      timeout             : 300
      # Title of the dual list box.
      title               : 'Items'
      # Filter is enabled by default
      filter              : yes

  # Intern varibles
  dataName = 'dualSelect'
  selectors =
    unselectedSelect  : '.dual-select-container[data-area="unselected"] select'
    selectedSelect    : '.dual-select-container[data-area="selected"] select'
    unselectedOptions : 'option:not([selected])' # FIXME: Need a btter selector
    selectedOptions   : 'option:selected'

  # Render the page layout from options
  render = ($select, options) ->
    # Rener the layout
    $instance = $(templates.layout(options))

    # Construct the control buttons
    controlButtons =
      # Button: data-type
      allToSelected         : 'ats'
      unselectedToSelected  : 'uts'
      selectedToUnselected  : 'stu'
      allToUnselected       : 'atu'
    $btnContainer = $instance.find('.control-buttons')
    for controlButton, dataType of controlButtons
      $(templates.buttons[controlButton])
        .addClass(dataType)
        .data('control', dataType)
        .prop('disabled', yes)
        .appendTo($btnContainer)

    # Adjust controls display/hide and control buttons margin
    marginTop = 80
    if not options.title or options.title is ''
      $instance.find('h4').hide()
      marginTop -= 34
    if not options.filter or options.filter is ''
      $instance.find('.filter').hide()
      marginTop -= 34
    $instance.find('.control-buttons').css('margin-top', "#{marginTop}px")
 
    # Initizlie the selected/unselected options
    [$unselectedSelect, $selectedSelect] = getSelects($instance)
    $unselectedOptions = $select.find(selectors['unselectedOptions'])
      .clone()
      .prop('selected', no)
    $selectedOptions = $select.find(selectors['selectedOptions'])
      .clone()
      .prop('selected', no)
    $unselectedSelect.append $unselectedOptions
    $selectedSelect.append $selectedOptions
    refreshControls($instance, no, $unselectedSelect, $selectedSelect)
    $instance

  getSelects = ($instance) ->
    $unselectedSelect = $instance.find(selectors['unselectedSelect'])
    $selectedSelect = $instance.find(selectors['selectedSelect'])
    [$unselectedSelect, $selectedSelect]

  refreshControls = ($instance, cancelSelected, $unselectedSelect, $selectedSelect) ->
    $buttons = $instance.find('.control-buttons button')
    unless $unselectedSelect? and $selectedSelect?
      [$unselectedSelect, $selectedSelect] = getSelects($instance)
    $buttons.prop('disabled', yes)
    unselectedOptionsCount = $unselectedSelect.children().size()
    selectedOptionsCount = $selectedSelect.children().size()
    $instance.find('div[data-area="unselected"] .count').text unselectedOptionsCount
    $instance.find('div[data-area="selected"] .count').text selectedOptionsCount
    if unselectedOptionsCount > 0
      $buttons.filter('.ats').prop('disabled', no)
    if $unselectedSelect.find(selectors['selectedOptions']).size() > 0
      $buttons.filter('.uts').prop('disabled', no)
    if $selectedSelect.find(selectors['selectedOptions']).size() > 0
      $buttons.filter('.stu').prop('disabled', no)
    if selectedOptionsCount > 0
      $buttons.filter('.atu').prop('disabled', no)
    if cancelSelected
      $unselectedSelect.children().prop('selected', no)
      $selectedSelect.children().prop('selected', no)

  refreshSelectedOptions = ($select, $selectedSelect) ->
    selectedValues = $selectedSelect.children().map (i, el) ->
       $(el).val()
    $select.children().prop('selected', no).filter((i, el) ->
      $(el).val() in selectedValues
    ).prop('selected', yes)

  # Listen events and do the actions
  addEventsListener = ($select, $instance, options) ->
    delay = do ->
      timer = null
      (callback, timeout) ->
        clearTimeout timer
        timer = setTimeout timeout, callback

    events =
      # Select changed event, toggle the controll buttons disabled status.
      'change select': (evt) ->
        refreshControls($instance, no)
      'dblclick select': (evt) ->
        $el = $(evt.currentTarget)
        if $el.parents('.dual-select-container').data('area') is 'selected'
          return $instance.find('.control-buttons .stu').trigger('click')
        $instance.find('.control-buttons .uts').trigger('click')
      'click .control-buttons button': (evt) ->
        $unselectedSelect = $instance.find(selectors['unselectedSelect'])
        $selectedSelect   = $instance.find(selectors['selectedSelect'])
        callbacks =
          'ats': ->
            callbacks.uts $unselectedSelect.children()
          'uts': ($selectedOptions) ->
            unless $selectedOptions?
              $selectedOptions = $unselectedSelect.find('option:selected')
            $selectedOptions.clone().appendTo($selectedSelect)
            $selectedOptions.remove()
          'stu': ($selectedOptions) ->
            unless $selectedOptions?
              $selectedOptions = $selectedSelect.find('option:selected')
            $selectedOptions.clone().appendTo($unselectedSelect)
            $selectedOptions.remove()
          'atu': ->
            callbacks.stu $selectedSelect.children()

        $el = $(evt.currentTarget)
        callbacks[$el.data('control')]()
        refreshControls($instance, yes)
        $instance.find('.uts, .stu').prop('disabled', yes)
        refreshSelectedOptions($select, $selectedSelect)
      'keyup input.filter': (evt) ->
        $el = $(evt.currentTarget)
        $select = null
        refreshCount = ->
          $el.parent().find('.count').text $select.find('option:visible').size()
  
        delay options.timeout, ->
          value = $el.val().trim().toLowerCase()
          area = $el.parents('.dual-select-container').data('area')
          $select = $instance.find(selectors["#{area}Select"])
          if value is ''
            $select.children().show()
            return refreshCount()
          $select.children().hide().filter((i, option) ->
            $option = $(option)
            $option.text().toLowerCase().indexOf(value) >= 0 or $option.val() is value
          ).show()
          refreshCount()

    for key, listener of events
      keyArray = key.split(' ')
      eventName = keyArray[0]
      selector = keyArray.slice(1).join(' ')
      # Event delegation
      $instance.on("#{eventName}.delegateEvents", selector, listener)
    $instance

  # Destroy the instance
  destroy = ($select)->
    return unless $select.data(dataName)
    $select.data(dataName).remove()
    $select.removeData(dataName).show()

  # Export dualSelect plugin to jquery
  $.fn.dualSelect = (options, selected) ->
    # Validator, throw will stop working while meeting errors
    $.each @, ->
      # dualSelect only accept SELECT element input
      unless @nodeName is 'SELECT'
        throw 'dualSelect only accept select element'
      # Dual select can't contains in dual select
      if $(@).parents('.dual-select').size() > 0
        throw 'dualSelect can not be initizied in dualSelect'
    
    # Start working
    instances = $.map @, (element, index)->
      # The jQuery object
      $select = $(element)

      # Destroy dualSelect instance when option is 'destroy'
      return destroy($select) if options is 'destroy'

      # HTML options
      htmlOptions =
        title       : $select.data('title')
        timeout     : $select.data('timeout')
        textLength  : $select.data('textLength')
        moveAllBtn  : $select.data('moveAllBtn')
        maxAllBtn   : $select.data('maxAllBtn')

      # Merge the options, generate final options
      options = $.extend {}, $.dualSelect.defaults, htmlOptions, options

      # Destroy previous dualSelect instance and re-construct.
      destroy($select) if $select.data(dataName)?

      # Do work
      $instance = render($select, options)
      $instance.data('options', options)
      addEventsListener($select, $instance, options)
      $instance.insertAfter($select)
      $select.data(dataName, $instance).hide()
      $instance[0]
    $(instances)
