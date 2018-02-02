require 'rails_helper'

describe 'legacy', :type => :request do
  describe 'search query' do
    it 'is redirected to search results page with original query and filters' do
      legacy_params = {
        "q" => 'foo',
        "res_format" => 'bar',
        "publisher" => 'baz',
        "license_id-is-ogl" => "true"
      }

      get "/data/search?#{legacy_params.to_query}"

      expected_params = {
        "q" => 'foo',
        "filters" => {
          "format" => 'bar',
          "publisher" => 'baz',
          "licence" => 'uk-ogl'
        }
      }

      expect(response).to redirect_to(search_path(expected_params))
    end
  end

  describe 'dataset page' do
    it 'redirects to the latest slugged URL' do
      legacy_name = 'a-legacy-name'
      dataset = DatasetBuilder.new.with_legacy_name(legacy_name).build
      index([dataset])

      get "/dataset/#{legacy_name}"

      expect(response).to redirect_to(dataset_url(dataset[:short_id], dataset[:name]))
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'datafile resources' do
    let(:legacy_dataset_name) { 'a-legacy-name' }
    let(:datafile) { CSV_DATAFILE.with_indifferent_access }
    let(:dataset) do
      DatasetBuilder
        .new
        .with_legacy_name(legacy_dataset_name)
        .with_datafiles([datafile])
        .build
    end

    context 'when the datafile can not be found' do
      it 'returns a not found error page' do
        get "/dataset/#{legacy_dataset_name}/resource/#{datafile[:uuid]}"

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the datafile exists' do
      before { index([dataset]) }

      it 'redirects to the datefile preview page' do
        get "/dataset/#{legacy_dataset_name}/resource/#{datafile[:uuid]}"

        location = datafile_preview_path(
          dataset[:short_id], dataset[:name], datafile[:short_id]
        )

        expect(response).to redirect_to(location)
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe 'contact page' do
    it 'redirects to the support page' do
      get '/contact'

      expect(response).to redirect_to(support_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'cookies page' do
    it 'redirects to the cookies page' do
      get '/cookies-policy'

      expect(response).to redirect_to(cookies_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end
end
