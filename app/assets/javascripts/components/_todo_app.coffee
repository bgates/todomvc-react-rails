{header, h1, input, label, ul, li, div, button, section, span, strong, footer, a} = React.DOM

ENTER_KEY = 13
ESCAPE_KEY = 27

TodoApp = React.createClass
  getInitialState: ->
    todos: []
    newTodoField: ''
    editing: null
    editText: ''

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

  handleToggle: (item) ->
    todos = @state.todos.map (todo) ->
      if item is todo
        title: todo.title
        completed: !todo.completed
      else
        todo
    @setState todos: todos

  handleToggleAll: (event) ->
    todos = @state.todos.map (todo) ->
      title: todo.title
      completed: event.target.checked
    @setState todos: todos

  handleEdit: (item) ->
    @setState
      editing: item
      editText: item.title

  handleEditChange: (event) ->
    @setState editText: event.target.value

  handleEditKeyDown: (event) ->
    if event.which is ESCAPE_KEY
      @setState
        editText: ''
        editing: null
    else if event.which is ENTER_KEY
      @handleEditSubmit(event)

  handleEditSubmit: (event) ->
    val = @state.editText.trim()
    if val
      todos = @state.todos.map (todo) =>
        if @state.editing is todo
          title: val
          completed: todo.completed
        else
          todo
    else
      todos = @state.todos.filter (todo) =>
        todo isnt @state.editing
    @setState
      todos: todos
      editText: ''
      editing: null

  handleClearCompleted: (event) ->
    todos = @state.todos.filter (todo) ->
      !todo.completed
    @setState todos: todos

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
        autoFocus: true
        ref: 'newField'
        onKeyDown: @handleNewTodoKeyDown
        onChange: @handleNewTodoChange
        value: @state.newTodoField

  renderSection: ->
    section id: 'main',
      input
        id: 'toggle-all'
        type: 'checkbox'
        checked: @state.todos.every (todo) ->
          todo.completed is true
        onChange: @handleToggleAll
      label htmlFor: 'toggle-all', 'Mark all as complete'
      ul id: 'todo-list', @renderTodoItems()

  renderTodoItems: ->
    [@renderTodoItem(item) for item in @state.todos]

  renderTodoItem: (item) ->
    classString = ''
    classString += 'completed' if item.completed
    classString += ' editing' if item is @state.editing
    liProps = {}
    liProps['className'] = classString if classString.length
    li liProps,
      div className: 'view',
        input
          className: 'toggle'
          type: 'checkbox'
          checked: item.completed is true
          onChange: @handleToggle.bind(@, item)
        label onDoubleClick: @handleEdit.bind(@, item),
          item.title
        button className: 'destroy'
      input
        className: 'edit'
        value: @state.editText
        onChange: @handleEditChange
        onKeyUp: @handleEditKeyDown
        onBlur: @handleEditSubmit

  renderFooter: ->
    activeCount = @state.todos.reduce((prev, curr) ->
      if curr.completed
        prev
      else
        prev + 1
    , 0)
    completedCount = @state.todos.length - activeCount
    footer id: 'footer',
      span id: 'todo-count',
        strong null, activeCount
        " item#{if activeCount is 1 then '' else 's'} left"
      ul id: 'filters',
        li null,
          a className: 'selected', href: '#/', 'All'
        li null,
          a href: '#/active', 'Active'
        li null,
          a href: '#/completed', 'Completed'
      @renderClearCompletedButton(completedCount) if completedCount

  renderClearCompletedButton: (completedCount) ->
    button
      id: 'clear-completed'
      onClick: @handleClearCompleted
      , "Clear completed (#{completedCount})"

window.TodoApp = TodoApp
