{header, h1, input, label, ul, li, div, button, section, span, strong, footer, a} = React.DOM

ENTER_KEY = 13

TodoApp = React.createClass
  getInitialState: ->
    todos: []
    newTodoField: ''

  handleNewTodoChange: (event) ->
    @setState newTodoField: event.target.value

  handleNewTodoKeyDown: (event) ->
    return if event.which != ENTER_KEY
    event.preventDefault()
    val = @refs.newField.getDOMNode().value.trim()
    if val
      @setState
        todos: @state.todos.concat([{ title: val, completed: false }])
        newTodoField: ''

  render: ->
    div null,
      @renderHeader()
      @renderSection() if @state.todos.length
      @renderFooter() if @state.todos.length

  renderHeader: ->
    header id: 'header',
      h1 null, 'todos'
      input
        id: 'new-todo'
        placeholder: 'What needs to be done?'
        autofocus: true
        ref: 'newField'
        onKeyDown: @handleNewTodoKeyDown
        onChange: @handleNewTodoChange
        value: @state.newTodoField

  renderSection: ->
    section id: 'main',
      input id: 'toggle-all', type: 'checkbox'
      label htmlFor: 'toggle-all', 'Mark all as complete'
      ul id: 'todo-list', @renderTodoItems()

  renderTodoItems: ->
    [@renderTodoItem(item) for item in @state.todos]

  renderTodoItem: (item) ->
    li className: item.completed,
      div className: 'view',
        input
          className: 'toggle'
          type: 'checkbox'
          checked: item.completed is true
        label null, item.title
        button className: 'destroy'
      input className: 'edit', value: item.title

  renderFooter: ->
    footer id: 'footer',
      span id: 'todo-count',
        strong null, '1'
        ' item left'
      ul id: 'filters',
        li null,
          a className: 'selected', href: '#/', 'All'
        li null,
          a href: '#/active', 'Active'
        li null,
          a href: '#/completed', 'Completed'
      button id: 'clear-completed', 'Clear completed (1)'

window.TodoApp = TodoApp
