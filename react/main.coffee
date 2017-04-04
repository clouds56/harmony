class HelloMessage extends React.Component
  R: React.DOM
  render: () ->
    @R.div null, "Hello #{@props.name}"
helloMessage = React.createFactory(HelloMessage)

ReactDOM.render (helloMessage name:"Clouds"), document.getElementById("main")