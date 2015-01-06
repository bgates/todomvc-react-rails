{header, h1, input, label, ul, li, div, button, section, span, strong, footer, a} = React.DOM

TodoApp = React.createClass(
  render: ->
    div null,
      header id: 'header',
        h1 null, 'todos'
        input id: 'new-todo', placeholder: 'What needs to be done?', autofocus: true
      section id: 'main',
        input id: 'toggle-all', type: 'checkbox'
        label htmlFor: 'toggle-all', 'Mark all as complete'
        ul id: 'todo-list',
          li className: 'completed',
            div className: 'view',
              input className: 'toggle', type: 'checkbox', checked: true
              label null, 'Create a TodoMVC template'
              button className: 'destroy'
            input className: 'edit', value: 'Create a TodoMVC template'
          li null,
            div className: 'view',
              input className: 'toggle', type: 'checkbox'
              label null, 'Rule the web'
              button className: 'destroy'
            input className: 'edit', value: 'Rule the web'
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
)

window.TodoApp = TodoApp
