books = [
	{ uuid: "100001", title: "The Little Prince", author: "Antoine de Saint-Exupery" },
	{ uuid: "100002", title: "Pride and Prejudice", author: "Jane Austen" },
	{ uuid: "100003", title: "The Left Hand of Darkness", author: "Ursula K. Le Guin" }
]

books.each do |attributes|
	Book.find_or_create_by!(uuid: attributes[:uuid]) do |book|
		book.assign_attributes(attributes)
	end
end

readers = [
	{ uuid: "200001", full_name: "Ada Lovelace", email: "ada@example.com" },
	{ uuid: "200002", full_name: "Alan Turing", email: "alan@example.com" },
	{ uuid: "200003", full_name: "Grace Hopper", email: "grace@example.com" }
]

readers.each do |attributes|
	Reader.find_or_create_by!(uuid: attributes[:uuid]) do |reader|
		reader.assign_attributes(attributes)
	end
end

returned_rental = Rental.find_or_create_by!(book: Book.find_by!(uuid: "100001"), user_id: Reader.find_by!(uuid: "200001").id) do |rental|
	rental.assign_attributes(
		borrowed_at: 45.days.ago,
		duration_date: 15.days.ago,
		returned_at: 10.days.ago,
		reading_status: "returned"
	)
end
returned_rental.book.update!(availability_status: "available")

active_rental = Rental.find_or_create_by!(book: Book.find_by!(uuid: "100002"), user_id: Reader.find_by!(uuid: "200002").id) do |rental|
	rental.assign_attributes(
		borrowed_at: 27.days.ago,
		duration_date: 3.days.from_now.to_date,
		reading_status: "borrowed"
	)
end
active_rental.book.update!(availability_status: "borrowed")

Book.find_by!(uuid: "100003").update!(availability_status: "available")
