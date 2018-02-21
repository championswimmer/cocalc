###
FrameTitleBar - title bar in a frame, in the frame tree
###

{debounce} = require('underscore')

{ButtonGroup, Button}   = require('react-bootstrap')
{React, rclass, rtypes} = require('../smc-react')
{Icon, Space, Tip}      = require('../r_misc')
{IS_TOUCH} = require('../feature')
misc = require('smc-util/misc')

title_bar_style =
    background    : '#eee'
    borderTop     : '1px solid rgb(204,204,204)'
    borderLeft    : '1px solid rgb(204,204,204)'
    borderRight   : '1px solid rgb(204,204,204)'
    verticalAlign : 'middle'
    lineHeight    : '20px'
    overflow      : 'hidden'
    textOverflow  : 'ellipsis'
    minHeight     : '24px'

path_style =
    whiteSpace  : 'nowrap'
    fontSize    : '13px'
    paddingLeft : '5px'
    color       : '#333'

if IS_TOUCH
    button_size = 'small'
    close_style = undefined
else
    button_size = 'xsmall'
    close_style = background:title_bar_style.background, border:'transparent', height:0

exports.FrameTitleBar = rclass
    propTypes :
        actions    : rtypes.object.isRequired
        active_id  : rtypes.string
        id         : rtypes.string
        path       : rtypes.string
        deletable  : rtypes.bool
        read_only  : rtypes.bool
        is_full    : rtypes.bool
        is_only    : rtypes.bool    # is the only frame -- so don't show delete or full buttons at all.

    getInitialState: ->
        display_buttons : IS_TOUCH  # must always show on touch devices

    shouldComponentUpdate: (next, state) ->
        return @state.display_buttons != state.display_buttons or \
               @props.active_id  != next.active_id or \
               @props.id         != next.id or \
               @props.path       != next.path or \
               @props.deletable  != next.deletable or \
               @props.is_full    != next.is_full or \
               @props.is_only    != next.is_only or \
               @props.read_only  != next.read_only

    click_close: ->
        @props.actions.close_frame(@props.id)

    render_x: ->
        disabled = @props.is_full or @props.is_only or not @props.deletable
        <ButtonGroup style={marginLeft:'5px', float:'right'} key={'x'}>
            {@render_full() if @props.is_full or @state.display_buttons or @props.active_id == @props.id}
            <Button
                style    = {close_style}
                disabled = {disabled}
                key      = {'close'}
                bsSize   = {button_size}
                onClick  = {@click_close} >
                <Icon name={'times'}/>
            </Button>
        </ButtonGroup>

    render_full: ->
        if @props.is_full
            <Button
                disabled = {@props.is_only}
                key     = {'compress'}
                bsSize  = {button_size}
                bsStyle = {'warning'}
                onClick = {=> @props.actions.set_frame_full()} >
                <Icon name={'compress'}/>
            </Button>
        else
            <Button
                disabled = {@props.is_only}
                key     = {'expand'}
                bsSize  = {button_size}
                onClick = {=> @props.actions.set_frame_full(@props.id)} >
                <Icon name={'expand'}/>
            </Button>

    render_split_row: ->
        <Button
            disabled = {@props.is_full}
            key      = {'split-row'}
            bsSize   = {button_size}
            onClick  = {=>@props.actions.split_frame('row', @props.id)} >
            <Icon name='columns' rotate={'90'} />
        </Button>

    render_split_col: ->
        <Button
            disabled = {@props.is_full}
            key      = {'split-col'}
            bsSize   = {button_size}
            onClick  = {=>@props.actions.split_frame('col', @props.id)} >
            <Icon name='columns' />
        </Button>

    render_zoom_out: ->
        <Button
            key     = {'font-increase'}
            bsSize  = {button_size}
            onClick = {=>@props.actions.decrease_font_size(@props.id)}
            >
            <Icon style={fontSize:'5pt'} name={'font'} />
        </Button>

    render_zoom_in: ->
        <Button
            key     = {'font-decrease'}
            onClick = {=>@props.actions.increase_font_size(@props.id)}
            bsSize  = {button_size}
            >
            <Icon style={fontSize:'9pt'} name={'font'} />
        </Button>

    render_find_replace_group: ->
        <ButtonGroup key={'find-group'}>
            <Button
                key      = {'find'}
                onClick  = {=>@props.actions.find(@props.id)}
                bsSize   = {button_size} >
                <Icon name='search' />
            </Button>
            <Button
                key      = {'replace'}
                onClick  = {=>@props.actions.replace(@props.id)}
                disabled = {@props.read_only}
                bsSize   = {button_size} >
                <Icon name='exchange' />
            </Button>
            <Button
                key      = {'goto-line'}
                onClick  = {=>@props.actions.goto_line(@props.id)}
                bsSize   = {button_size} >
                <Icon name='bolt' />
            </Button>
        </ButtonGroup>

    render_copy_group: ->
        <ButtonGroup key={'copy'}>
            <Button
                key      = {'cut'}
                onClick  = {=>@props.actions.cut(@props.id)}
                disabled = {@props.read_only}
                bsSize   = {button_size} >
                <Icon name={'scissors'} />
            </Button>
            <Button
                key      = {'copy'}
                onClick  = {=>@props.actions.copy(@props.id)}
                bsSize  = {button_size} >
                <Icon name={'copy'} />
            </Button>
            <Button
                key     = {'paste'}
                onClick = {debounce((=>@props.actions.paste(@props.id)), 200, true)}
                disabled = {@props.read_only}
                bsSize  = {button_size} >
                <Icon name={'paste'} />
            </Button>
        </ButtonGroup>

    render_zoom_group: ->
        <ButtonGroup key={'zoom'}>
            {@render_zoom_out()}
            {@render_zoom_in()}
        </ButtonGroup>

    render_split_group: ->
        <ButtonGroup  key={'split'}>
            {@render_split_row()}
            {@render_split_col()}
        </ButtonGroup>

    render_buttons: ->
        <span style={float:'right'}>
            {@render_copy_group()}
            <Space />
            {@render_find_replace_group()}
            <Space />
            {@render_zoom_group()}
            <Space />
            {@render_split_group()}
        </span>

    render_path: ->
        <span style={path_style}>
            <Tip
                placement = {'bottom'}
                title     = {@props.path}
            >
                {misc.path_split(@props.path).tail}
            </Tip>
        </span>

    cancel_hide: ->
        if @_hide?
            clearTimeout(@_hide)
            delete @_hide

    show_buttons: ->
        if not @state.display_buttons
            @cancel_hide()
            @setState(display_buttons:true)

    hide_buttons: ->
        @cancel_hide()
        @_hide = setTimeout((=>@cancel_hide(); @setState(display_buttons:false)), 1500)

    componentWillUnmount: ->
        @cancel_hide()

    render: ->
        <div
            style        = {title_bar_style}
            onMouseEnter = {@show_buttons if not IS_TOUCH}
            onMouseLeave = {@hide_buttons if not IS_TOUCH}
            onMouseOver  = {@show_buttons if not IS_TOUCH}
            >
            {@render_path()}
            {@render_x()}
            {@render_buttons() if @state.display_buttons or @props.id == @props.active_id}
        </div>