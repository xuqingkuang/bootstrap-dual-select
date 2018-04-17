#
# jQuery Dual Select plugin with Bootstrap
# http://kxq.io
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
      # Filter is enabled by default
      filter              : yes
      # Max selectable items
      maxSelectable       : 0
      # Timeout for when a filter search is started.
      timeout             : 300
      # Title of the dual list box.
      title               : 'Items'

  # Intern varibles
  dataName = 'dualSelect'
  selectors =
    unselectedSelect  : '.dual-select-container[data-area="unselected"] select'
    selectedSelect    : '.dual-select-container[data-area="selected"] select'
    unselectedOptions : 'option:not([selected])' # FIXME: Need a btter selector
    selectedOptions   : 'option:selected'
    visibleOptions    : 'option:visible'

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
    [$unselectedSelect, $selectedSelect] = getInstanceSelects($instance)
    $selectedOptions = $select.find(selectors['selectedOptions'])
      .clone()
      .prop('selected', no)
    # FIXME: Need a better solution to get the unselected options
    # $unselectedOptions = $select.find(selectors['unselectedOptions'])
    #  .clone()
    #  .prop('selected', no)
    # Here's a workaround
    selectedOptionsValue = $selectedOptions.map (index, el) -> $(el).val()
    $unselectedOptions = $select.children().filter((index, el) ->
      $(el).val() not in selectedOptionsValue
    )
      .clone()
      .prop('selected', no)

    # Render the selects
    $unselectedSelect.append $unselectedOptions
    $selectedSelect.append $selectedOptions
    refreshControls($instance, no, options, $unselectedSelect, $selectedSelect)
    refreshOptionsCount($instance, 'option', $unselectedSelect, $selectedSelect)
    $instance

  getInstanceSelects = ($instance) ->
    $unselectedSelect = $instance.find(selectors['unselectedSelect'])
    $selectedSelect = $instance.find(selectors['selectedSelect'])
    [$unselectedSelect, $selectedSelect]

  refreshControls = ($instance, cancelSelected, options, $unselectedSelect, $selectedSelect) ->
    $buttons = $instance.find('.control-buttons button')
    maxReached = no
    unless $unselectedSelect? and $selectedSelect?
      [$unselectedSelect, $selectedSelect] = getInstanceSelects($instance)
    $buttons.prop('disabled', yes)
    $unselectedSelect.prop('disabled', no)
    counts = refreshOptionsCount($instance, 'option', $unselectedSelect, $selectedSelect)
    [unselectedOptionsCount, selectedOptionsCount] = counts
    if unselectedOptionsCount > 0
      $buttons.filter('.ats').prop('disabled', no)
    if $unselectedSelect.find(selectors['selectedOptions']).length > 0
      $buttons.filter('.uts').prop('disabled', no)
    if $selectedSelect.find(selectors['selectedOptions']).length > 0
      $buttons.filter('.stu').prop('disabled', no)
    if selectedOptionsCount > 0
      $buttons.filter('.atu').prop('disabled', no)
    # Max selectable option
    if options.maxSelectable isnt 0
      if selectedOptionsCount >= options.maxSelectable
        $buttons.filter('.ats').prop('disabled', yes)
        $buttons.filter('.uts').prop('disabled', yes)
        $unselectedSelect.prop('disabled', yes)
        maxReached = yes
      if $unselectedSelect.find(':selected').length + selectedOptionsCount > options.maxSelectable
        $buttons.filter('.ats').prop('disabled', yes)
        $buttons.filter('.uts').prop('disabled', yes)
        maxReached = yes
      if unselectedOptionsCount > options.maxSelectable
        $buttons.filter('.ats').prop('disabled', yes)
        maxReached = yes
      if maxReached
        $instance.trigger('maxReached')
    # Cancel the selected attributes
    if cancelSelected
      $unselectedSelect.children().prop('selected', no)
      $selectedSelect.children().prop('selected', no)

  refreshOptionsCount = ($instance, optionSelector, $unselectedSelect, $selectedSelect) ->
    optionSelector = selectors['visibleOptions'] unless optionSelector?
    unless $unselectedSelect? and $selectedSelect?
      [$unselectedSelect, $selectedSelect] = getInstanceSelects($instance)
    unselectedOptionsCount = $unselectedSelect.find(optionSelector).length
    selectedOptionsCount = $selectedSelect.find(optionSelector).length
    $instance.find('div[data-area="unselected"] .count').text unselectedOptionsCount
    $instance.find('div[data-area="selected"] .count').text selectedOptionsCount
    [unselectedOptionsCount, selectedOptionsCount]

  refreshSelectedOptions = ($select, $selectedSelect) ->
    # Update orignal select values
    selectedValues = $selectedSelect.children().map (i, el) ->
       $(el).val()
    $select.children().prop('selected', no).filter((i, el) ->
      $(el).val() in selectedValues
    ).prop('selected', yes)
    # Trigger original select change event
    $select.trigger('change')

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
        refreshControls($instance, no, options)
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
        refreshControls($instance, yes, options)
        $instance.find('.uts, .stu').prop('disabled', yes)
        refreshSelectedOptions($select, $selectedSelect)
      'keyup input.filter': (evt) ->
        $el = $(evt.currentTarget)
        $instanceSelect = null
        delay options.timeout, ->
          value = $el.val().trim().toLowerCase()
          area = $el.parents('.dual-select-container').data('area')
          $instanceSelect = $instance.find(selectors["#{area}Select"])
          if value is ''
            $instanceSelect.children().show()
          else
            $instanceSelect.children().hide().filter((i, option) ->
              $option = $(option)
              $option.text().toLowerCase().indexOf(value) >= 0 or $option.val() is value
            ).show()
          refreshOptionsCount($instance)

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
      if $(@).parents('.dual-select').length > 0
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
      options.maxSelectable = parseInt options.maxSelectable
      if isNaN options.maxSelectable
        throw 'Option maxSelectable must be integer'

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
