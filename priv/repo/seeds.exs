# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BookStore.Repo.insert!(%BookStore.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias BookStore.Store.Book
alias BookStore.Store.Author
alias BookStore.Store.AuthorBook
alias BookStore.Repo

# Clear existing data
Repo.delete_all(AuthorBook)
Repo.delete_all(Book)
Repo.delete_all(Author)

# Authors data
authors_data = [
  %{name: "Harper Lee"},
  %{name: "George Orwell"},
  %{name: "F. Scott Fitzgerald"},
  %{name: "J.R.R. Tolkien"},
  %{name: "Jane Austen"},
  %{name: "J.D. Salinger"},
  %{name: "Charlotte Brontë"},
  %{name: "Emily Brontë"},
  %{name: "John Steinbeck"},
  %{name: "Herman Melville"},
  %{name: "Fyodor Dostoevsky"},
  %{name: "Homer"},
  %{name: "Miguel de Cervantes"},
  %{name: "Leo Tolstoy"},
  %{name: "Dante Alighieri"},
  %{name: "Aldous Huxley"},
  %{name: "Gabriel García Márquez"}
]

# Insert authors and store IDs with names for reference
authors =
  Enum.map(authors_data, fn author_data ->
    {:ok, author} =
      %Author{}
      |> Author.changeset(author_data)
      |> Repo.insert()

    {author_data.name, author.id}
  end)
  |> Map.new()

# Classic books data with author references
books_data = [
  %{
    title: "To Kill a Mockingbird",
    description:
      "A novel by Harper Lee about racial inequality through the eyes of a child in Alabama during the Great Depression.",
    price: "12.99",
    authors: ["Harper Lee"]
  },
  %{
    title: "1984",
    description:
      "A dystopian novel by George Orwell depicting a totalitarian surveillance state and the rebellion of a government worker.",
    price: "11.99",
    authors: ["George Orwell"]
  },
  %{
    title: "Animal Farm",
    description:
      "An allegorical novella by George Orwell reflecting events leading to the Russian Revolution and the Stalinist era.",
    price: "9.99",
    authors: ["George Orwell"]
  },
  %{
    title: "The Great Gatsby",
    description:
      "F. Scott Fitzgerald's novel depicting the tragic story of Jay Gatsby and his pursuit of the American Dream in the Jazz Age.",
    price: "10.99",
    authors: ["F. Scott Fitzgerald"]
  },
  %{
    title: "The Lord of the Rings",
    description:
      "J.R.R. Tolkien's epic high-fantasy tale following the quest to destroy the One Ring to prevent the Dark Lord Sauron from conquering Middle-earth.",
    price: "15.99",
    authors: ["J.R.R. Tolkien"]
  },
  %{
    title: "The Hobbit",
    description:
      "J.R.R. Tolkien's children's fantasy novel about the adventures of Bilbo Baggins, a hobbit who embarks on a quest to win a share of dragon's treasure.",
    price: "14.99",
    authors: ["J.R.R. Tolkien"]
  },
  %{
    title: "Pride and Prejudice",
    description:
      "Jane Austen's romantic novel about the emotional development of Elizabeth Bennet who learns about the repercussions of hasty judgments.",
    price: "8.99",
    authors: ["Jane Austen"]
  },
  %{
    title: "The Catcher in the Rye",
    description:
      "J.D. Salinger's novel about teenage alienation and loss of innocence, following Holden Caulfield's experiences in New York City.",
    price: "9.99",
    authors: ["J.D. Salinger"]
  },
  %{
    title: "Brave New World",
    description:
      "Aldous Huxley's dystopian novel set in a futuristic World State where citizens are engineered through artificial reproduction.",
    price: "10.99",
    authors: ["Aldous Huxley"]
  },
  %{
    title: "Jane Eyre",
    description:
      "Charlotte Brontë's novel following the emotions and experiences of its eponymous character, including her growth into adulthood and her love for Mr. Rochester.",
    price: "11.99",
    authors: ["Charlotte Brontë"]
  },
  %{
    title: "The Grapes of Wrath",
    description:
      "John Steinbeck's novel set during the Great Depression, following the Joads, a poor family of tenant farmers driven from their Oklahoma home by drought and economic hardship.",
    price: "13.99",
    authors: ["John Steinbeck"]
  },
  %{
    title: "Moby Dick",
    description:
      "Herman Melville's novel about the obsessive quest of Captain Ahab for revenge on Moby Dick, the white whale that bit off his leg.",
    price: "12.99",
    authors: ["Herman Melville"]
  },
  %{
    title: "Crime and Punishment",
    description:
      "Fyodor Dostoevsky's novel exploring the moral dilemmas of Raskolnikov, an impoverished ex-student who formulates a plan to kill an unscrupulous pawnbroker.",
    price: "10.99",
    authors: ["Fyodor Dostoevsky"]
  },
  %{
    title: "The Brothers Karamazov",
    description:
      "Fyodor Dostoevsky's final novel exploring faith, doubt, morality through the story of three brothers and their father's murder.",
    price: "14.99",
    authors: ["Fyodor Dostoevsky"]
  },
  %{
    title: "The Odyssey",
    description:
      "Homer's epic poem following the Greek hero Odysseus and his journey home after the fall of Troy.",
    price: "9.99",
    authors: ["Homer"]
  },
  %{
    title: "Don Quixote",
    description:
      "Miguel de Cervantes' novel about a man who becomes so infatuated with tales of chivalry that he loses his sanity and believes he is a knight errant.",
    price: "13.99",
    authors: ["Miguel de Cervantes"]
  },
  %{
    title: "War and Peace",
    description:
      "Leo Tolstoy's epic novel set in Russia during the Napoleonic era, following the interconnected lives of five aristocratic families.",
    price: "16.99",
    authors: ["Leo Tolstoy"]
  },
  %{
    title: "The Divine Comedy",
    description:
      "Dante Alighieri's long narrative poem describing his journey through Hell, Purgatory, and Paradise.",
    price: "11.99",
    authors: ["Dante Alighieri"]
  }
]

# Insert books and create author associations
Enum.each(books_data, fn %{
                           title: title,
                           description: description,
                           price: price,
                           authors: author_names
                         } ->
  # Insert book
  {:ok, book} =
    %Book{}
    |> Book.changeset(%{title: title, description: description, price: price})
    |> Repo.insert()

  # Create author associations
  Enum.each(author_names, fn author_name ->
    author_id = Map.get(authors, author_name)

    if author_id do
      %AuthorBook{}
      |> AuthorBook.changeset(%{author_id: author_id, book_id: book.id})
      |> Repo.insert!()
    end
  end)
end)

IO.puts(
  "Inserted #{length(authors_data)} authors and #{length(books_data)} books with associations"
)
