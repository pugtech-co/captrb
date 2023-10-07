module Captrb
  class Calc
    def cosine_similarity(vector_a, vector_b)
      dot_product = 0
      norm_a = 0
      norm_b = 0
    
      vector_a.each_with_index do |a_val, i|
        b_val = vector_b[i]
        dot_product += a_val * b_val
        norm_a += a_val ** 2
        norm_b += b_val ** 2
      end
    
      dot_product / (Math.sqrt(norm_a) * Math.sqrt(norm_b))
    end
    
    
    def strings_ranked_by_relatedness(query_embedding, note_embeddings, top_n=100)
      # Compute similarity scores
      scores_and_notes = note_embeddings.map do |note_id, embedding|
        [note_id, cosine_similarity(query_embedding, embedding)]
      end
    
      # Sort by score in descending order and take top_n
      sorted_scores_and_notes = scores_and_notes.sort_by { |_note, score| -score }.first(top_n)
    
      # Separate notes and scores
      sorted_notes, sorted_scores = sorted_scores_and_notes.transpose
    
      return sorted_notes, sorted_scores
    end
  end
end
