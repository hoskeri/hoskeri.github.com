---
title: How to get the pixel size of text rendered by pango
layout: default
---

Often, when writing Gtk apps, you need to resize the container or window based on the size of the text you wish to render. Here is a simple program in python on how to do it.
Of course this works in any language with `gtk` and `Pango` bindings.

{% highlight python %}
    #!/usr/bin/python
    import gtk
    import pango
    
    w = gtk.Window()
    l = gtk.Label("")
    e = gtk.Entry()
    v = gtk.VBox()
    
    def e_changed(e):
      l.set_text(e.get_text())
      co = l.get_pango_context()
      la = pango.Layout(co)
    
      la.set_text(l.get_text())
      print la.get_pixel_size()
    
    e.connect('changed', e_changed)
    
    v.add(l)
    v.add(e)
    w.add(v)
    
    w.show_all()
    w.show()
    gtk.main()
{% endhighlight %}
