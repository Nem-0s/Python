#Dane logowania do bazy danych Login:Kierownik Hasło:12345
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter.simpledialog import askstring
import mysql.connector
mydb = None
cursor = None
def pokaz_interfejs():
    login_window.withdraw()  # Ukryj okno logowania
    wybierz_tabele()  # Wywołaj funkcję wyboru tabeli

# Tworzenie głównego okna
# Funkcja logowania
def zaloguj():
    global mydb
    host = "localhost"
    username = username_entry.get()
    password = password_entry.get()
    database = "magazyn"

    try:
        mydb = mysql.connector.connect(
            host=host,
            user=username,
            password=password,
            database=database
        )
        cursor = mydb.cursor()

        cursor.execute("SELECT * FROM Uzytkownicy WHERE NazwaUzytkownika = %s AND Haslo = %s", (username, password))
        user = cursor.fetchone()

        if user:
            # Zalogowano pomyślnie
            messagebox.showinfo("Sukces", "Zalogowano pomyślnie!")
            # Możesz dodać kod do przełączania na interfejs po zalogowaniu
            pokaz_interfejs()
            login_window.destroy()
        else:
            messagebox.showerror("Błąd", "Nieprawidłowy użytkownik lub hasło.")
    except mysql.connector.Error as err:
        messagebox.showerror("Błąd", f"Błąd połączenia z bazą danych: {err}")

# Funkcja do wyświetlania danych z wybranej tabeli
def pokaz_interfejs():
    login_window.destroy()  # Zniszcz okno logowania

    # Reszta kodu interfejsu, który był wcześniej

# Okno logowania
login_window = tk.Tk()
login_window.title("Logowanie")

frame = ttk.Frame(login_window)
frame.pack(padx=20, pady=20)


# Pole użytkownika
username_label = ttk.Label(frame, text="Nazwa użytkownika:")
username_label.pack()
username_entry = ttk.Entry(frame)
username_entry.pack()

# Pole hasła
password_label = ttk.Label(frame, text="Hasło:")
password_label.pack()
password_entry = ttk.Entry(frame, show="*")  # Ukryj wpisywane znaki
password_entry.pack()


# Przycisk logowania
login_button = ttk.Button(frame, text="Zaloguj", command=zaloguj)
login_button.pack()
login_window.mainloop()
# Utworzenie kursora

# Wykonanie zapytania, które pokaże aktualnego użytkownika
cursor = mydb.cursor()
cursor.execute("SELECT CURRENT_USER()")

# Pobranie wyniku zapytania
current_user = cursor.fetchone()[0]
current_user = current_user.split("@", 1)[0]
cursor.execute(f"SELECT klient_id FROM uzytkownicy WHERE NazwaUzytkownika='{current_user}'")
wynik = cursor.fetchone()
id=wynik[0]

naglowki_tabeli = {
    "Produkty": ["ID", "Nazwa", "Opis", "Cena", "IloscDostepna"],
    "Klienci": ["ID", "Imie", "Nazwisko", "Adres", "Numertelefonu"],
    "Zamowienia": ["ID", "Data zamówienia", "Klient", "Status zamówienia"],
    "Uzytkownicy": ["ID", "Nazwa użytkownika", "Haslo", "Rola", "Klient_id"]
}

# Funkcja do wyświetlania danych z wybranej tabeli
def sprawdz_uprawnienia(uzytkownik, potrzebne_uprawnienia):
    if True:
        return True
    else:
        return False

def wyswietl_tabele(nazwa_tabeli, komenda):
    cursor = mydb.cursor()
    if current_user == 'klient1' and nazwa_tabeli == "Klienci" and komenda == "SELECT":
        cursor.execute(f"SELECT * FROM {nazwa_tabeli} WHERE ID='{int(id)}'")
    else:
        cursor.execute(f"{komenda} * FROM {nazwa_tabeli}")
    
    wyniki = cursor.fetchall()
    for i, row in enumerate(wyniki):
        tree.insert("", "end", values=row)

def edytuj_rekord():
    selected_table = menu_var.get()
    selected_item = tree.selection()
    
    if not selected_item:
        messagebox.showwarning("Błąd", "Proszę wybrać rekord do edycji.")
        return

    if sprawdz_uprawnienia(current_user, f"UPDATE {selected_table}"):
        # Pobierz dane z wybranego rekordu
        rekord_do_aktualizacji = tree.item(selected_item, "values")
        
        # Otwórz okno dialogowe do edycji rekordu (bez ID)
        nowe_dane = askstring("Edycja rekordu", "Wprowadź nowe dane (oddzielone przecinkiem, bez ID):",
                              initialvalue=", ".join(rekord_do_aktualizacji[1:]))  # Pomijamy pierwszy element (ID)
        print(nowe_dane)
        if nowe_dane is not None:
            nowe_dane = nowe_dane.split(", ")  # Rozdziel dane po przecinkach
            
            # Ustal, które kolumny są dostępne w danej tabeli (bez ID)
            dostepne_kolumny = naglowki_tabeli.get(selected_table, [])[1:]
            
            # Zaktualizuj tylko dostępne kolumny
            update_query = f"UPDATE {selected_table} SET "
            for i, kolumna in enumerate(dostepne_kolumny):
                if i > 0:
                    update_query += ", "
                update_query += f"{kolumna}=%s"
            update_query += f" WHERE {naglowki_tabeli[selected_table][0]}=%s"
            print(update_query)
            print (len(nowe_dane), len(dostepne_kolumny))
            # Sprawdź, czy liczba dostarczonych wartości zgadza się z liczbą dostępnych kolumn (bez ID)
            if len(nowe_dane) != len(dostepne_kolumny):
                messagebox.showerror("Błąd", "Niepoprawna liczba pól.")
                return

            # Tutaj wykonaj operację UPDATE w bazie danych, włączając kolumnę ID w filtrze
            nowe_dane.append(rekord_do_aktualizacji[0])
            print(nowe_dane)
            cursor.execute(update_query, nowe_dane)
            
            mydb.commit()  # Zatwierdź zmiany w bazie danych
            messagebox.showinfo("Sukces", "Rekord został zaktualizowany.")

            # Odśwież widok tabeli
            wybierz_tabele()
    else:
        messagebox.showerror("Brak uprawnień", "Nie masz uprawnień do edycji tej tabeli.")

# Funkcje do obsługi wyboru z menu
def wybierz_tabele(*args):
    selected_table = menu_var.get()
    tree.delete(*tree.get_children())

    if sprawdz_uprawnienia(current_user, f"SELECT *FROM {selected_table}"):
        # Ustaw nagłówki kolumn w zależności od wybranej tabeli
        if selected_table in naglowki_tabeli:
            tree.heading("#1", text="")
            tree.heading("#2", text="")
            tree.heading("#3", text="")
            tree.heading("#4", text="")
            tree.heading("#5", text="")
            tree.heading("#6", text="")
            for i, naglowek in enumerate(naglowki_tabeli[selected_table]):
                tree.heading(f"#{i+1}", text=naglowek)

        komenda = komenda_var.get()  # Pobierz wybraną komendę (SELECT lub UPDATE)
        wyswietl_tabele(selected_table, komenda)
    else:
        messagebox.showerror("Brak uprawnień", "Nie masz uprawnień do wyświetlenia tej tabeli.")



# Tworzenie głównego okna
root = tk.Tk()
root.title("Aplikacja do obsługi bazy danych")

frame = ttk.Frame(root)
frame.pack(padx=20, pady=20)

# Wybór tabeli i komendy (modyfikacja wybierania tabeli)
menu_var = tk.StringVar()
print("Wybierz tabelę: ")
menu = tk.OptionMenu(frame, menu_var, "Produkty", "Klienci", "Zamowienia", "Uzytkownicy")
menu_var.set("Produkty")
menu.pack()

menu_var.trace("w", wybierz_tabele)

komenda_var = tk.StringVar()
komenda_var.set("SELECT")

# Przycisk do edycji rekordu
edytuj_button = ttk.Button(frame, text="Edytuj rekord", command=edytuj_rekord)
edytuj_button.pack()

# Tabela do wyświetlania danych
tree = ttk.Treeview(frame, columns=("", "", "", "", "", ""))
tree.heading("#1", text="")
tree.heading("#2", text="")
tree.heading("#3", text="")
tree.heading("#4", text="")
tree.heading("#5", text="")
tree.heading("#6", text="")
tree.pack()

root.mainloop()