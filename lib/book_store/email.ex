defmodule BookStore.Email do
  import Swoosh.Email
  alias BookStore.Mailer
  alias BookStore.Store
  alias BookStore.Accounts.User

  @pdf_path "priv/repo/herman-melville-moby-dick.pdf"
  @from_email "bookstore@example.com"

  @doc """
  Sends a purchase confirmation email to the user with PDF attachments for each purchased book.
  """
  def send_purchase_confirmation(order, user) do
    # Preload library items with books
    library_items = Store.get_library_items_for_order(order.id)

    # Create an email with all the purchased books as attachments
    email =
      new()
      |> to(user.email)
      |> from(@from_email)
      |> subject("Your BookStore Order Confirmation ##{order.id}")
      |> html_body(purchase_confirmation_html(order, library_items))
      |> text_body(purchase_confirmation_text(order, library_items))
      |> add_book_attachments(library_items)

    # Send the email
    case Mailer.deliver(email) do
      {:ok, _metadata} ->
        {:ok, order}
      {:error, reason} ->
        # Just log the error, don't interrupt the purchase process
        require Logger
        Logger.error("Failed to send purchase confirmation email: #{inspect reason}")
        {:ok, order}
    end
  end

  defp add_book_attachments(email, library_items) do
    Enum.reduce(library_items, email, fn item, email_acc ->
      attachment_name = "#{item.book.title |> String.replace(" ", "-")}.pdf"

      email_acc
      |> attachment(
        Swoosh.Attachment.new(
          # Using the same sample PDF for all books in this example
          @pdf_path,
          filename: attachment_name,
          content_type: "application/pdf"
        )
      )
    end)
  end

  defp purchase_confirmation_html(order, library_items) do
    books_html = Enum.map_join(library_items, "", fn item ->
      """
      <tr>
        <td style="padding: 12px; border-bottom: 1px solid #e2e8f0;">#{item.book.title}</td>
        <td style="padding: 12px; border-bottom: 1px solid #e2e8f0;">$#{item.book.price}</td>
      </tr>
      """
    end)

    """
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <div style="background-color: #1e40af; color: white; padding: 20px; text-align: center;">
        <h1 style="margin: 0;">Thank you for your purchase!</h1>
        <p style="margin-top: 10px;">Order ##{order.id}</p>
      </div>

      <div style="padding: 20px; background-color: #f9fafb;">
        <h2>Order Summary</h2>
        <p>Your books are attached to this email and are also available in your library.</p>

        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f3f4f6;">
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid #e2e8f0;">Book</th>
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid #e2e8f0;">Price</th>
            </tr>
          </thead>
          <tbody>
            #{books_html}
          </tbody>
          <tfoot>
            <tr style="background-color: #f3f4f6;">
              <td style="padding: 12px; font-weight: bold;">Total</td>
              <td style="padding: 12px; font-weight: bold;">$#{order.total_price}</td>
            </tr>
          </tfoot>
        </table>

        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
          <p>Thank you for shopping with BookStore!</p>
          <p>If you have any questions about your order, please contact us at support@bookstore.example.com</p>
        </div>
      </div>
    </div>
    """
  end

  defp purchase_confirmation_text(order, library_items) do
    books_text = Enum.map_join(library_items, "\n", fn item ->
      "- #{item.book.title}: $#{item.book.price}"
    end)

    """
    Thank you for your purchase!
    Order ##{order.id}

    Order Summary:
    Your books are attached to this email and are also available in your library.

    #{books_text}

    Total: $#{order.total_price}

    Thank you for shopping with BookStore!
    If you have any questions about your order, please contact us at support@bookstore.example.com
    """
  end
end
