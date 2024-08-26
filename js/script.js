let cart = [];

function addToCart(itemName, itemPrice) {
    const item = { name: itemName, price: itemPrice, quantity: 1 };
    const existingItem = cart.find(cartItem => cartItem.name === item.name);

    if (existingItem) {
        existingItem.quantity++;
    } else {
        cart.push(item);
    }

    alert(`${itemName} ha sido añadido al carrito.`);
    updateCart();
}

function updateCart() {
    const cartItemsContainer = document.getElementById('cart-items');
    cartItemsContainer.innerHTML = '';

    cart.forEach(item => {
        const cartItem = document.createElement('li');
        cartItem.textContent = `${item.name} - $${item.price} x ${item.quantity}`;
        cartItemsContainer.appendChild(cartItem);
    });

    calculateTotal();
}

function calculateTotal() {
    const totalPrice = cart.reduce((total, item) => total + (item.price * item.quantity), 0);
    document.getElementById('total-price').textContent = `Total: $${totalPrice}`;
}

function placeOrder() {
    if (cart.length === 0) {
        alert('Tu carrito está vacío. Agrega algún platillo antes de realizar un pedido.');
        return;
    }

    alert('Gracias por tu pedido. Está en camino!');
    cart = [];
    updateCart();
}

function loadMenu() {
    fetch('data/menu.json')
        .then(response => response.json())
        .then(data => {
            const menu = data.menu;
            const menuContainer = document.querySelector('.menu');
            
            menu.forEach(item => {
                const foodItem = document.createElement('div');
                foodItem.className = 'food-items';
                
                foodItem.innerHTML = `
                    <img src="images/${item.name.toLowerCase().replace(/ /g, '-')}.jpg" alt="${item.name}">
                    <div class="details">
                        <div class="details-sub">
                            <h5>${item.name}</h5>
                            <h5 class="price">$${item.price}</h5>
                        </div>
                        <p>${item.description}</p>
                        <button onclick="addToCart('${item.name}', ${item.price})">Añadir al carrito</button>
                    </div>
                `;
                
                menuContainer.appendChild(foodItem);
            });
        })
        .catch(error => console.error('Error al cargar el menú:', error));
}

loadMenu();