package MainFrame;

use Wx qw[:everything];
use base qw(Wx::Frame);

use KeywordProtocol;
use KeywordStore;
use SettingsFrame;

my $dbh = KeywordStore::connect();

use Misc;

use Data::Dumper;
use FreezeThaw qw(freeze thaw);
use strict;
use warnings;

our $title = "ParDiff Keyword Tracker";
our $main_frame = undef;

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: MainFrame::new

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
    $main_frame = $self;
    
    $self->{status} = 'stopped';

    $self->{dates} = KeywordStore::get_dates($dbh);

	$self->{list_box_1} = Wx::ListBox->new($self, -1, wxDefaultPosition, wxDefaultSize, [], wxLB_SINGLE | wxLB_NEEDED_SB);

	$self->{text_ctrl_1} = Wx::TextCtrl->new($self, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_READONLY | wxTE_CENTRE);

	$self->{check_button} = Wx::Button->new($self, -1, "check");
	$self->{settings_button} = Wx::Button->new($self, -1, "setting");
	$self->{list_ctrl_1} = Wx::ListCtrl->new($self, -1, wxDefaultPosition, wxDefaultSize, wxLC_REPORT|wxSUNKEN_BORDER);

    my $xx = Wx::ListItem->new();
    $xx->SetText('Test');
    
    $self->{keywords} = KeywordStore::get_keywords($dbh);
    $self->redraw_keywords();

    $self->{rank_timer_1} = Wx::Timer->new($self, -1);
    # $self->{rank_info};

	$self->__set_properties();
	$self->__do_layout();

    $self->display_status('Ready');

    Wx::Event::EVT_TIMER($self, $self->{rank_timer_1}->GetId, \&rank_timer_evt);
	Wx::Event::EVT_LISTBOX($self, $self->{list_box_1}->GetId, \&date_list_click);
	Wx::Event::EVT_BUTTON($self, $self->{check_button}->GetId, \&check_button_evt);
	Wx::Event::EVT_BUTTON($self, $self->{settings_button}->GetId, \&settings_button_evt);

# end wxGlade
	return $self;

}


sub __set_properties {
	my $self = shift;

# begin wxGlade: MainFrame::__set_properties

	$self->SetTitle($title);
	$self->SetSize(Wx::Size->new(835, 722));
	# $self->{list_box_1}->SetSelection(0);

    $self->ReloadDate();

# end wxGlade
}

sub ReloadDate {
    my $self = shift;

    $self->{list_box_1}->Set($self->{dates});
}

sub __do_layout {
	my $self = shift;

	$self->{sizer_1} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_2} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_3} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_8} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_7} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_6} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_1}->Add($self->{list_box_1}, 0, wxEXPAND, 0);
	$self->{sizer_6}->Add($self->{text_ctrl_1}, 0, wxEXPAND, 0);
	$self->{sizer_3}->Add($self->{sizer_6}, 4, wxEXPAND, 0);
	$self->{sizer_7}->Add($self->{check_button}, 0, wxEXPAND, 0);
	$self->{sizer_3}->Add($self->{sizer_7}, 1, wxEXPAND, 0);
	$self->{sizer_8}->Add($self->{settings_button}, 0, 0, 0);
	$self->{sizer_3}->Add($self->{sizer_8}, 1, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{sizer_3}, 1, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{list_ctrl_1}, 10, wxEXPAND, 0);
	$self->{sizer_1}->Add($self->{sizer_2}, 1, wxEXPAND, 0);
	$self->SetSizer($self->{sizer_1});
	$self->Layout();

    $self->load_data_from_date(Misc::get_current_date());
# end wxGlade
}

sub date_list_click {
	my ($self, $event) = @_;

    warn 'Selected: ' . $event->GetSelection() . "\n";

    print Dumper($event);
    $self->load_data_from_date($self->{dates}[$event->GetSelection()]);

	warn "Event handler (date_list_click) not implemented";
	$event->Skip;

# end wxGlade
}

sub rank_timer_evt {
    my ($self, $event) = @_;
    my $result = $KeywordProtocol::q_worker_main->dequeue_nb();
    
    # warn "Got a result\n";
        
    if ($result) {
        my @results = thaw($result);
        my $rank = $results[0];

        if ($self->{status} eq 'running') {
            # record value
            $self->set_keyword_google_ranks($rank);

            # repainting result
            $self->redraw_keywords;

            # continue working
            my $next_keyword = $self->get_next_keyword($rank->{keyword});

            if ($next_keyword) {
                $KeywordProtocol::q_main_worker->enqueue($next_keyword);
                $self->display_status("Checking Google rank for '$next_keyword'");
            }
            else {
                # ended
                $self->{check_button}->SetLabel('Check');
                $self->{status} = 'stopped';
                $self->{rank_timer_1}->Stop;
                $self->reset_next_keyword;
                $self->display_status("Ready");
                return;
            }

        }
    }

    $self->{rank_timer_1}->Start(10, 1);

}

sub check_button_evt {
	my ($self, $event) = @_;

    if ($self->{status} eq 'running') {
        $self->{status} = 'stopped';

        $self->display_status('Ready');

        $self->{check_button}->SetLabel('Check');
        $self->{rank_timer_1}->Stop();
    }
    else {
        # now clear the date selection
        foreach my $option ($self->{list_box_1}->GetSelection()) {
            $self->{list_box_1}->Deselect($option);
        }
        my @dates = @{$self->{dates}};
        $self->{list_box_1}->SetSelection($#dates, 1);

        $self->switch_to_today();

        $self->reset_next_keyword();
        my $next_keyword = $self->get_next_keyword();

        $KeywordProtocol::q_main_worker->enqueue($next_keyword);
        $self->{rank_timer_1}->Start(10, 1);

        $self->{status} = 'running';
        $self->{check_button}->SetLabel('Stop');

        $self->display_status("Checking Google rank for '$next_keyword'");
    }

	# $event->Skip;

# end wxGlade
}


sub settings_button_evt {
	my ($self, $event) = @_;

    my $settings_frame = SettingsFrame->new();
	$self->Show(0);
    $settings_frame->Show(1);
}

sub reload_keywords {
    my ($self) = @_;
    $self->{keywords} = KeywordStore::get_keywords($dbh);
}


sub redraw_keywords {
    my ($self) = @_;
    $self->{list_ctrl_1}->ClearAll();

    $self->{list_ctrl_1}->InsertColumnString(0, 'keywords', wxLIST_FORMAT_LEFT, 100);
    $self->{list_ctrl_1}->InsertColumnString(1, 'Google Ranks');

    my $count = 0;
    foreach my $keyword (@{$self->{keywords}}) {
        my $idx = $self->{list_ctrl_1}->InsertStringItem($count, $keyword);
        $count++;
        
        $self->{list_ctrl_1}->SetItem($idx, 1, $self->get_keyword_google_ranks($keyword));
    }
}

sub get_keyword_google_ranks {
    my ($self, $keyword) = @_;

    if ($self->{rank_info}{$keyword}) {
        return $self->{rank_info}{$keyword};
    }
    else {
        return 'N/A';
    }
}

sub get_next_keyword {
    my ($self, $keyword) = @_;

    my @keywords = @{$self->{keywords}};

    if (!$keyword) {
        return $keywords[0];
    }

    if ($self->{finished}) {
        return undef;
    }

    my $count = 0;
    my $target = $#keywords;

    foreach my $k (@keywords) {
        if ($k eq $keyword) {
            warn($k, ' - ' , $keyword);
                    
            $target = $count;
        }

        $count++;
    }

    if ($target == $#keywords) {
        $self->{finished} = 1;
        return undef;
    }

    print 'returned ' .  $keywords[$target + 1] . "\n";
    warn Dumper($self->{keywords});
    return $keywords[$target + 1];
}

sub reset_next_keyword {
    my ($self) = @_;
    
    $self->{finished} = undef;
}

sub set_keyword_google_ranks {
    my ($self, $rank) = @_;

    my $keyword = $rank->{keyword};

    KeywordStore::set_ranks($dbh, $rank->{keyword}, Misc::get_current_date(), 'google', $rank->{rank});

    if ((!$self->{rank_info}{$keyword})  || ($self->{rank_info}{$keyword} < $rank->{rank})) {
        $self->{rank_info}{$keyword} = $rank->{rank};
    }
}

sub display_status {
    my ($self, $info) = @_;
    
    $self->{text_ctrl_1}->Clear;
    $self->{text_ctrl_1}->SetValue($info);
}

sub switch_to_today {
    my ($self) = @_;
    $self->{date} = Misc::get_current_date();

    $self->load_data_from_date($self->{date});
}

sub load_data_from_date {
    my ($self, $date) = @_;

    $self->SetTitle($title . " - " . $date);

    $self->{date} = $date;
    
    delete $self->{rank_info};
    foreach my $keyword (@{$self->{keywords}}) {
        $self->{rank_info}{$keyword} = KeywordStore::get_ranks($dbh, $keyword, $date, 'google');
    }

    $self->redraw_keywords();
}

1;

