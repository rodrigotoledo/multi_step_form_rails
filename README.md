# Roteiro

## Criando projeto

```bash
rails new multi_step_form --css=tailwind -T
cd multi_step_form
```

## Modelo de usuario

```bash
rails generate model User name:string email:string age:integer address:text step:integer
```

## Gerando controller de Users

```bash
rails generate controller Users new show
```

## Conteudo de action new

```erb
<h1 class="text-3xl font-extrabold text-gray-800 mb-6">Create New User</h1>

<%= turbo_frame_tag "user_form", class: "bg-white shadow rounded-lg p-6" do %>
  <%= render "users/steps/step_1" %>
<% end %>
```

Action `new`

```ruby
def new
  @user = User.new(step: 1)
end
```

### Steps

Step 1
Partial `users/steps/_step_1.html.erb`

```erb
<h2 class="text-2xl font-bold text-gray-800 mb-4">Step 1: Personal Information</h2>

<%= form_with model: @user, url: users_path(id: params[:id]), method: :post, local: false, class: "space-y-6" do |form| %>
  <!-- Renderiza os erros -->
  <%= render 'users/errors' %>

  <!-- Campo para nome -->
  <div class="flex flex-col">
    <%= form.label :name, "Name", class: "text-sm font-medium text-gray-700" %>
    <%= form.text_field :name, placeholder: "Enter your name", class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2  focus:ring-opacity-50" %>
  </div>

  <!-- Campo para email -->
  <div class="flex flex-col">
    <%= form.label :email, "Email", class: "text-sm font-medium text-gray-700" %>
    <%= form.email_field :email, placeholder: "Enter your email", class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2  focus:ring-opacity-50" %>
  </div>

  <!-- Botão de submit -->
  <div class="flex justify-end">
    <%= form.submit "Next", class: "px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md shadow hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
  </div>
<% end %>
```

Partial `users/_errors.html.erb`

```erb
<% if @user.errors.any? %>
  <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative">
    <h3 class="font-bold text-lg">The following errors occurred:</h3>
    <ul class="list-disc pl-5 mt-2">
      <% @user.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Visualizando a aplicacao

Colocando ponto inicial em `routes.rb` e acoes para `users`

```ruby
root "users#new"
resources :users, only: [:new, :create, :update, :show] do
  member do
    patch :update_step
  end
end
```

Pequeno ajuste no layout

```erb
<main class="container mx-auto mt-28 px-5 flex flex-col">
```

Action `create`

```ruby
def create
  @user = User.find_by(id: params[:id])
  @user ||= User.new
  @user.attributes = user_params.merge(step: 1)
  if @user.save
    render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_2")
  else
    render :new
  end
end
```

Metodos privados

```ruby
  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :age, :address, :step)
  end
```

Step 2
Partial `users/steps/_step_2.html.erb`

```erb
<h2 class="text-2xl font-bold text-gray-800 mb-4">Step 2: Additional Information</h2>

<%= form_with model: @user, url: user_path(@user), method: :patch, local: false, class: "space-y-6" do |form| %>
  <!-- Renderiza os erros -->
  <%= render 'users/errors' %>

  <!-- Campo para idade -->
  <div class="flex flex-col">
    <%= form.label :age, "Age", class: "text-sm font-medium text-gray-700" %>
    <%= form.number_field :age, placeholder: "Enter your age", min: 0, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2  focus:ring-opacity-50" %>
  </div>

  <!-- Campo oculto para o step -->
  <%= form.hidden_field :step, value: 2 %>

  <!-- Botão de submit -->
  <div class="flex justify-end space-x-4">
    <%= form.submit "Next", data: { turbo_method: :patch, turbo_stream: true, turbo_frame: "user_form" }, class: "px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md shadow hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
  </div>
<% end %>

<!-- Link para voltar -->
<div class="mt-4">
  <%= link_to "Back", update_step_user_path(@user, step: 1), data: { turbo_method: :patch, turbo_stream: true }, class: "text-sm text-blue-600 hover:underline" %>
</div>
```

Salvando informacoes ou indo ao passo anterior

```ruby
before_action :set_user, only: %i[show update update_step]

def update
  if @user.update(user_params)
    if @user.step == 3
      render turbo_stream: turbo_stream.update("user_form", template: "users/show")
    else
      render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{@user.step+1}")
    end
  else
    render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{@user.step}")
  end
end

def update_step
  @user.update(step: params[:step])
  render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{params[:step]}")
end
```

Step 3
Partial `users/steps/_step_3.html.erb`

```erb
<h2 class="text-2xl font-bold text-gray-800 mb-4">Step 3: Address</h2>

<%= form_with model: @user, url: user_path(@user), method: :patch, local: false, class: "space-y-6" do |form| %>
  <!-- Renderiza os erros -->
  <%= render 'users/errors' %>

  <!-- Campo de texto para endereço -->
  <div class="flex flex-col">
    <%= form.label :address, "Address", class: "text-sm font-medium text-gray-700" %>
    <%= form.text_area :address, placeholder: "Enter your address", rows: 4, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2  focus:ring-opacity-50" %>
  </div>

  <!-- Campo oculto para o step -->
  <%= form.hidden_field :step, value: 3 %>

  <!-- Botão de submit -->
  <div class="flex justify-end space-x-4">
    <%= form.submit "Finish", class: "px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md shadow hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
  </div>
<% end %>

<!-- Link para voltar -->
<div class="mt-4">
  <%= link_to "Back", update_step_user_path(@user, step: 2), data: { turbo_method: :patch, turbo_stream: true }, class: "text-sm text-blue-600 hover:underline" %>
</div>
```

E finalmente a action `show`

```ruby
def show; end
```

```erb
<div class="max-w-4xl mx-auto bg-white p-6">
  <h1 class="text-3xl font-extrabold text-gray-800 mb-6">User Details</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <!-- Nome -->
    <div>
      <h2 class="text-lg font-medium text-gray-700">Name</h2>
      <p class="text-gray-900 text-lg"><%= @user.name %></p>
    </div>
    
    <!-- Email -->
    <div>
      <h2 class="text-lg font-medium text-gray-700">Email</h2>
      <p class="text-gray-900 text-lg"><%= @user.email %></p>
    </div>
    
    <!-- Idade -->
    <% if @user.age.present? %>
      <div>
        <h2 class="text-lg font-medium text-gray-700">Age</h2>
        <p class="text-gray-900 text-lg"><%= @user.age %></p>
      </div>
    <% end %>

    <!-- Endereço -->
    <% if @user.address.present? %>
      <div class="md:col-span-2">
        <h2 class="text-lg font-medium text-gray-700">Address</h2>
        <p class="text-gray-900 text-lg"><%= @user.address %></p>
      </div>
    <% end %>
  </div>
</div>
```

### Validacao do model

```rb
class User < ApplicationRecord
  validates :name, :email, presence: true, if: -> { step == 1 }
  validates :age, numericality: { only_integer: true }, if: -> { step == 2 }
  validates :address, presence: true, if: -> { step == 3 }
end
```